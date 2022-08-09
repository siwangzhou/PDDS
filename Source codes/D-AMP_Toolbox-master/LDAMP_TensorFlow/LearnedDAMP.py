__author__ = 'cmetzler&alimousavi'

import numpy as np
import tensorflow as tf

def SetNetworkParams(new_height_img, new_width_img,new_channel_img, new_filter_height,new_filter_width,\
                     new_num_filters,new_n_DnCNN_layers,new_n_DAMP_layers, new_sampling_rate,\
                     new_BATCH_SIZE,new_sigma_w,new_n,new_m,new_training,use_adaptive_weights=False):
    global height_img, width_img, channel_img, filter_height, filter_width, num_filters, n_DnCNN_layers, n_DAMP_layers,\
        sampling_rate, BATCH_SIZE, sigma_w, n, m, n_fp, m_fp, is_complex, training, adaptive_weights
    height_img = new_height_img
    width_img = new_width_img
    channel_img = new_channel_img
    filter_height = new_filter_height
    filter_width = new_filter_width
    num_filters = new_num_filters
    n_DnCNN_layers = new_n_DnCNN_layers
    n_DAMP_layers = new_n_DAMP_layers
    sampling_rate = new_sampling_rate
    BATCH_SIZE = new_BATCH_SIZE
    sigma_w = new_sigma_w
    n = new_n
    m = new_m
    n_fp = np.float32(n)
    m_fp = np.float32(m)
    is_complex=False#Just the default
    adaptive_weights=use_adaptive_weights
    training=new_training


def ListNetworkParameters():
    print('height_img = ', height_img)
    print('width_img = ', width_img)
    print('channel_img = ', channel_img)
    print('filter_height = ', filter_height)
    print('filter_width = ', filter_width)
    print('num_filters = ', num_filters)
    print('n_DnCNN_layers = ', n_DnCNN_layers)
    print('n_DAMP_layers = ', n_DAMP_layers)
    print('sampling_rate = ', sampling_rate)
    print('BATCH_SIZE = ', BATCH_SIZE)
    print('sigma_w = ', sigma_w)
    print('n = ', n)
    print('m = ', m)

#Form the measurement operators
def GenerateMeasurementOperators(mode):
    global is_complex
    if mode=='gaussian':
        is_complex=False
        A_val = np.float32(1. / np.sqrt(m_fp) * np.random.randn(m, n))# values that parameterize the measurement model. This could be the measurement matrix itself or the random mask with coded diffraction patterns.
        y_measured = tf.placeholder(tf.float32, [m, None])
        A_val_tf = tf.placeholder(tf.float32, [m, n])  #A placeholer is used so that the large matrix isn't put into the TF graph (2GB limit)

        def A_handle(A_vals_tf,x):
            return tf.matmul(A_vals_tf,x)

        def At_handle(A_vals_tf,z):
            return tf.matmul(A_vals_tf,z,adjoint_a=True)

    elif mode == 'complex-gaussian':
            is_complex = True
            A_val = np.complex64(1/np.sqrt(2.)*((1. / np.sqrt(m_fp) * np.random.randn(m,n))+1j*(1. / np.sqrt(m_fp) * np.random.randn(m,n))))
            y_measured = tf.placeholder(tf.complex64, [m, None])
            A_val_tf = tf.placeholder(tf.complex64, [m, n])  # A placeholer is used so that the large matrix isn't put into the TF graph (2GB limit)

            def A_handle(A_vals_tf, x):
                return tf.matmul(A_vals_tf, tf.complex(x,tf.zeros([n,BATCH_SIZE],dtype=tf.float32)))

            def At_handle(A_vals_tf, z):
                return tf.matmul(A_vals_tf, z, adjoint_a=True)
    elif mode=='coded-diffraction':
        is_complex=True
        A_val = np.zeros([n, 1]) + 1j * np.zeros([n, 1])
        A_val[0:n] = np.exp(1j*2*np.pi*np.random.rand(n,1))#The random sign vector

        global sparse_sampling_matrix
        rand_col_inds=np.random.permutation(range(n))
        rand_col_inds=rand_col_inds[0:m]
        row_inds = range(m)
        inds=zip(row_inds,rand_col_inds)
        vals=tf.ones(m, dtype=tf.complex64);
        sparse_sampling_matrix = tf.SparseTensor(indices=inds, values=vals, dense_shape=[m,n])

        A_val_tf = tf.placeholder(tf.complex64, [n, 1])
        def A_handle(A_val_tf, x):
            sign_vec = A_val_tf[0:n]
            signed_x = tf.multiply(sign_vec, tf.complex(x,tf.zeros([n,BATCH_SIZE],dtype=tf.float32)))
            signed_x = tf.reshape(signed_x, [height_img, width_img, BATCH_SIZE])
            signed_x=tf.transpose(signed_x)#Transpose because fft2d operates upon the last two axes
            F_signed_x = tf.fft2d(signed_x)
            F_signed_x=tf.transpose(F_signed_x)
            F_signed_x = tf.reshape(F_signed_x, [height_img * width_img, BATCH_SIZE])*1./np.sqrt(m_fp)#This is a different normalization than in Matlab because the FFT is implemented differently in Matlab
            out = tf.sparse_tensor_dense_matmul(sparse_sampling_matrix,F_signed_x,adjoint_a=False)
            return out

        def At_handle(A_val_tf, z):
            sign_vec=A_val_tf[0:n]
            z_padded = tf.sparse_tensor_dense_matmul(sparse_sampling_matrix,z,adjoint_a=True)
            z_padded = tf.reshape(z_padded, [height_img, width_img, BATCH_SIZE])
            z_padded=tf.transpose(z_padded)#Transpose because fft2d operates upon the last two axes
            Finv_z = tf.ifft2d(z_padded)
            Finv_z = tf.transpose(Finv_z)
            Finv_z = tf.reshape(Finv_z, [height_img*width_img, BATCH_SIZE])
            out = tf.multiply(tf.conj(sign_vec), Finv_z)*n_fp/np.sqrt(m)
            return out
    else:
        raise ValueError('Measurement mode not recognized')
    return [A_handle, At_handle, A_val, A_val_tf]

def GenerateMeasurementMatrix(mode):
    if mode == 'gaussian':
        A_val = np.float32(1. / np.sqrt(m_fp) * np.random.randn(m,n))  # values that parameterize the measurement model. This could be the measurement matrix itself or the random mask with coded diffraction patterns.
    elif mode=='complex-gaussian':
        A_val = np.complex64(1 / np.sqrt(2.) * ((1. / np.sqrt(m_fp) * np.random.randn(m, n)) + 1j * (1. / np.sqrt(m_fp) * np.random.randn(m, n))))
    elif mode=='coded-diffraction':
        A_val = np.zeros([n, 1]) + 1j * np.zeros([n, 1])
        A_val[0:n] = np.exp(1j*2*np.pi*np.random.rand(n,1))#The random sign vector
        rand_col_inds=np.random.permutation(range(n))
        rand_col_inds=rand_col_inds[0:m]
        row_inds = range(m)
        inds=zip(row_inds,rand_col_inds)
        vals=tf.ones(m, dtype=tf.complex64);
        sparse_sampling_matrix = tf.SparseTensor(indices=inds, values=vals, dense_shape=[m,n])
    else:
        raise ValueError('Measurement mode not recognized')
    return A_val

#Learned DAMP
def LDAMP(y,A_handle,At_handle,A_val,theta,x_true,tie):
    z = y
    xhat = tf.zeros([n, BATCH_SIZE], dtype=tf.float32)
    MSE_history=[]#Will be a list of n_DAMP_layers+1 lists, each sublist will be of size BATCH_SIZE
    NMSE_history=[]
    PSNR_history=[]
    (MSE_thisiter, NMSE_thisiter, PSNR_thisiter)=EvalError(xhat,x_true)
    MSE_history.append(MSE_thisiter)
    NMSE_history.append(NMSE_thisiter)
    PSNR_history.append(PSNR_thisiter)
    for iter in range(n_DAMP_layers):
        if is_complex:
            r = tf.complex(xhat,tf.zeros([n,BATCH_SIZE],dtype=tf.float32)) + At_handle(A_val,z)
            rvar = (1. / m_fp * tf.reduce_sum(tf.square(tf.abs(z)),axis=0))#In the latest version of TF, abs can handle complex values
        else:
            r = xhat + At_handle(A_val,z)
            rvar = (1. / m_fp * tf.reduce_sum(tf.square(tf.abs(z)),axis=0))
        (xhat,dxdr)=DnCNN_outer_wrapper(r, rvar,theta,tie,iter)
        if is_complex:
            z = y - A_handle(A_val, xhat) + n_fp / m_fp * tf.complex(dxdr,0.) * z
        else:
            z = y - A_handle(A_val, xhat) + n_fp / m_fp * dxdr * z
        (MSE_thisiter, NMSE_thisiter, PSNR_thisiter) = EvalError(xhat, x_true)
        MSE_history.append(MSE_thisiter)
        NMSE_history.append(NMSE_thisiter)
        PSNR_history.append(PSNR_thisiter)
    return xhat, MSE_history, NMSE_history, PSNR_history

#Learned DIT
def LDIT(y,A_handle,At_handle,A_val,theta,x_true,tie):
    z=y
    xhat = tf.zeros([n, BATCH_SIZE], dtype=tf.float32)
    MSE_history=[]#Will be a list of n_DAMP_layers+1 lists, each sublist will be of size BATCH_SIZE
    NMSE_history=[]
    PSNR_history=[]
    (MSE_thisiter, NMSE_thisiter, PSNR_thisiter)=EvalError(xhat,x_true)
    MSE_history.append(MSE_thisiter)
    NMSE_history.append(NMSE_thisiter)
    PSNR_history.append(PSNR_thisiter)
    for iter in range(n_DAMP_layers):
        if is_complex:
            r = tf.complex(xhat,tf.zeros([n,BATCH_SIZE],dtype=tf.float32)) + At_handle(A_val,z)
            rvar = (1. / m_fp * tf.reduce_sum(tf.square(tf.abs(z)),axis=0))#In the latest version of TF, abs can handle complex values
        else:
            r = xhat + At_handle(A_val,z)
            rvar = (1. / m_fp * tf.reduce_sum(tf.square(tf.abs(z)),axis=0))
        (xhat, dxdr) = DnCNN_outer_wrapper(r, 4.*rvar, theta, tie, iter)
        if is_complex:
            z = y - A_handle(A_val, xhat)
        else:
            z = y - A_handle(A_val, xhat)
        (MSE_thisiter, NMSE_thisiter, PSNR_thisiter) = EvalError(xhat, x_true)
        MSE_history.append(MSE_thisiter)
        NMSE_history.append(NMSE_thisiter)
        PSNR_history.append(PSNR_thisiter)
    return xhat, MSE_history, NMSE_history, PSNR_history

#Learned DGAMP
def LDGAMP(y,A_handle,At_handle,A_val,theta,x_true,tie):
    # GAMP notation is used here
    # LDGAMP does not presently support function handles: It does not work with the latest version of the code.
    wvar = tf.square(sigma_w)#Assume noise level is known. Could be learned
    Beta = 1.0 # For now perform no damping
    xhat = tf.zeros([n,BATCH_SIZE], dtype=tf.float32)
    xbar = xhat
    xvar = tf.ones((1,BATCH_SIZE), dtype=tf.float32)
    s = .00001*tf.ones((m, BATCH_SIZE), dtype=tf.float32)
    svar = .00001 * tf.ones((1, BATCH_SIZE), dtype=tf.float32)
    pvar = .00001 * tf.ones((1, BATCH_SIZE), dtype=tf.float32)
    OneOverM = tf.constant(float(1) / m, dtype=tf.float32)
    A_norm2=tf.reduce_sum(tf.square(A_val))
    OneOverA_norm2 = 1. / A_norm2
    MSE_history=[]#Will be a list of n_DAMP_layers+1 lists, each sublist will be of size BATCH_SIZE
    NMSE_history=[]
    PSNR_history=[]
    (MSE_thisiter, NMSE_thisiter, PSNR_thisiter)=EvalError(xhat,x_true)
    MSE_history.append(MSE_thisiter)
    NMSE_history.append(NMSE_thisiter)
    PSNR_history.append(PSNR_thisiter)
    for iter in range(n_DAMP_layers):
        pvar = Beta * A_norm2 * OneOverM * xvar + (1 - Beta) * pvar
        pvar = tf.maximum(pvar, .00001)
        p = tf.matmul(A_val, xhat) - pvar * s
        g, dg = g_out_gaussian(p, pvar, y, wvar)
        s = Beta * g + (1 - Beta) * s
        svar = -Beta * dg + (1 - Beta) * svar
        svar = tf.maximum(svar, .00001)
        rvar = OneOverA_norm2 * n / svar
        rvar = tf.maximum(rvar, .00001)
        xbar = Beta * xhat + (1 - Beta) * xbar
        r = xbar + rvar * tf.matmul(A_val, s,adjoint_a=True)
        (xhat, dxdr) = DnCNN_outer_wrapper(r, rvar, theta, tie, iter)
        xvar = dxdr * rvar
        xvar = tf.maximum(xvar, .00001)
        (MSE_thisiter, NMSE_thisiter, PSNR_thisiter) = EvalError(xhat, x_true)
        MSE_history.append(MSE_thisiter)
        NMSE_history.append(NMSE_thisiter)
        PSNR_history.append(PSNR_thisiter)
    return xhat, MSE_history, NMSE_history, PSNR_history

def init_vars_DnCNN(init_mu,init_sigma):
    weights = [None] * n_DnCNN_layers
    biases = [None] * n_DnCNN_layers
    #The batch normalization variables are not stored in theta. They are accessed using their names.
    #betas = [None] * n_DnCNN_layers#beta[0] and beta[-1] will be empty lists, as will moving_variances and moving_means
    #moving_variances = [None] * n_DnCNN_layers
    #moving_means = [None] * n_DnCNN_layers
    with tf.variable_scope("l0"):
        # Layer 1: filter_heightxfilter_width conv, channel_img inputs, num_filters outputs
        weights[0] = tf.Variable(
            tf.truncated_normal(shape=(filter_height, filter_width, channel_img, num_filters), mean=init_mu,
                                stddev=init_sigma), dtype=tf.float32, name="w")
        biases[0] = tf.Variable(tf.zeros(num_filters), dtype=tf.float32, name="b")
    for l in range(1, n_DnCNN_layers - 1):
        with tf.variable_scope("l" + str(l)):
            # Layers 2 to Last-1: filter_heightxfilter_width conv, num_filters inputs, num_filters outputs
            weights[l] = tf.Variable(
                tf.truncated_normal(shape=(filter_height, filter_width, num_filters, num_filters), mean=init_mu,
                                    stddev=init_sigma), dtype=tf.float32, name="w")
            biases[l] = tf.Variable(tf.zeros(num_filters), dtype=tf.float32, name="b")#Need to initialize this with a nz value

            #The following initializes the beta, moving_variance, and moving_mean variables
            tf.layers.batch_normalization(inputs=tf.placeholder(tf.float32,[BATCH_SIZE,height_img,width_img,num_filters]), center=True, scale=False, training=False, trainable=False,name='BN', reuse=False)
            #tf.layers.batch_normalization(inputs=tf.placeholder(tf.float32, [BATCH_SIZE, height_img, width_img, num_filters]), center=True,scale=False, training=training, trainable=False, name='BN', reuse=False)
            #tf.layers.batch_normalization(name='BN', reuse=False)
            #with tf.variable_scope("BN"):
                #betas[l] = tf.Variable(tf.zeros(num_filters),dtype=tf.float32,name="beta")
                #moving_variances[l] = tf.Variable(tf.zeros(num_filters), dtype=tf.float32, name="moving_variance")
                #moving_means[l] = tf.Variable(tf.zeros(num_filters), dtype=tf.float32, name="moving_mean")

    with tf.variable_scope("l" + str(n_DnCNN_layers - 1)):
        # Last Layer: filter_height x filter_width conv, num_filters inputs, 1 outputs
        weights[n_DnCNN_layers - 1] = tf.Variable(
            tf.truncated_normal(shape=(filter_height, filter_width, num_filters, 1), mean=init_mu,
                                stddev=init_sigma), dtype=tf.float32,
            name="w")  # The intermediate convolutional layers act on num_filters_inputs, not just channel_img inputs.
        biases[n_DnCNN_layers - 1] = tf.Variable(tf.zeros(1), dtype=tf.float32, name="b")
    return weights, biases#, betas, moving_variances, moving_means

## Evaluate Intermediate Error
def EvalError(x_hat,x_true):
    mse=tf.reduce_mean(tf.square(x_hat-x_true),axis=0)
    xnorm2=tf.reduce_mean(tf.square( x_true),axis=0)
    mse_thisiter=mse
    nmse_thisiter=mse/xnorm2
    psnr_thisiter=10.*tf.log(1./mse)/tf.log(10.)
    return mse_thisiter, nmse_thisiter, psnr_thisiter

## Evaluate Intermediate Error
def EvalError_np(x_hat,x_true):
    mse=np.mean(np.square(x_hat-x_true),axis=0)
    xnorm2=np.mean(np.square( x_true),axis=0)
    mse_thisiter=mse
    nmse_thisiter=mse/xnorm2
    psnr_thisiter=10.*np.log(1./mse)/np.log(10.)
    return mse_thisiter, nmse_thisiter, psnr_thisiter

## Output Denoiser Gaussian
def g_out_gaussian(phat,pvar,y,wvar):
    g=(y-phat)*1/(pvar+wvar)
    dg=-1/(pvar+wvar)
    return g, dg

## Output Denoiser Rician
def g_out_phaseless(phat,pvar,y,wvar):
    #Untested. To be used with D-prGAMP

    y_abs = y
    phat_abs = tf.abs(phat)
    B = 2.* tf.div(tf.multiply(y_abs,phat_abs),wvar+pvar)
    I1overI0 = tf.minimum(tf.div(B,tf.sqrt(tf.square(B)+4)),tf.div(B,0.5+tf.sqrt(tf.square(B)+0.25)))
    y_sca = tf.div(y_abs,1.+tf.div(wvar,pvar))
    phat_sca = tf.div(phat_abs,1.+tf.div(pvar,wvar))
    zhat = tf.multiply(tf.add(phat_sca,tf.multiply(y_sca,I1overI0)),tf.sign(phat))

    sigma2_z = tf.add(tf.add(tf.square(y_sca),tf.square(phat_sca)),tf.subtract(tf.div(1.+tf.multiply(B,I1overI0),tf.add(tf.div(1.,wvar),tf.div(1.,pvar))),tf.square(tf.abs(zhat))))

    g = tf.multiply(tf.div(1.,pvar),tf.subtract(zhat,phat))
    dg = tf.multiply(tf.div(1.,pvar),tf.subtract(tf.div(tf.reduce_mean(sigma2_z,axis=(1,2,3)),pvar),1))

    return g,dg

## Denoiser wrapper that selects which weights and biases to use
def DnCNN_outer_wrapper(r,rvar,theta,tie,iter):
    if tie:
        with tf.variable_scope("Iter0"):
            (xhat, dxdr) = DnCNN_wrapper(r, rvar, theta[0], reuse=True)
    elif adaptive_weights:
        rstd = 255. * tf.sqrt(tf.reduce_mean(rvar))  # To enable batch processing, I have to treat every image in the batch as if it has the same amount of effective noise
        def x_nl0(a=rstd,iter=iter,r=r,rvar=rvar,theta=theta):
            with tf.variable_scope("Adaptive_NL" + str(0)):
                (xhat, dxdr) = DnCNN_wrapper(r, rvar, theta[0], reuse=True)
            xhat = tf.Print(xhat, [iter], "used denoiser 0")
            return (xhat, dxdr)

        def x_nl1(a=rstd,iter=iter,r=r,rvar=rvar,theta=theta):
            with tf.variable_scope("Adaptive_NL" + str(1)):
                (xhat, dxdr) = DnCNN_wrapper(r, rvar, theta[1], reuse=True)
            xhat = tf.Print(xhat, [iter], "used denoiser 1")
            return (xhat, dxdr)

        def x_nl2(a=rstd,iter=iter,r=r,rvar=rvar,theta=theta):
            with tf.variable_scope("Adaptive_NL" + str(2)):
                (xhat, dxdr) = DnCNN_wrapper(r, rvar, theta[2], reuse=True)
            xhat = tf.Print(xhat, [iter], "used denoiser 2")
            return (xhat, dxdr)

        def x_nl3(a=rstd,iter=iter,r=r,rvar=rvar,theta=theta):
            with tf.variable_scope("Adaptive_NL" + str(3)):
                (xhat, dxdr) = DnCNN_wrapper(r, rvar, theta[3], reuse=True)
            xhat = tf.Print(xhat, [iter], "used denoiser 3")
            return (xhat, dxdr)

        def x_nl4(a=rstd,iter=iter,r=r,rvar=rvar,theta=theta):
            with tf.variable_scope("Adaptive_NL" + str(4)):
                (xhat, dxdr) = DnCNN_wrapper(r, rvar, theta[4], reuse=True)
            xhat = tf.Print(xhat, [iter], "used denoiser 4")
            return (xhat, dxdr)

        def x_nl5(a=rstd,iter=iter,r=r,rvar=rvar,theta=theta):
            with tf.variable_scope("Adaptive_NL" + str(5)):
                (xhat, dxdr) = DnCNN_wrapper(r, rvar, theta[5], reuse=True)
            xhat = tf.Print(xhat, [iter], "used denoiser 5")
            return (xhat, dxdr)

        def x_nl6(a=rstd,iter=iter,r=r,rvar=rvar,theta=theta):
            with tf.variable_scope("Adaptive_NL" + str(6)):
                (xhat, dxdr) = DnCNN_wrapper(r, rvar, theta[6], reuse=True)
            xhat = tf.Print(xhat, [iter], "used denoiser 6")
            return (xhat, dxdr)

        def x_nl7(a=rstd,iter=iter,r=r,rvar=rvar,theta=theta):
            with tf.variable_scope("Adaptive_NL" + str(7)) as scope:
                (xhat, dxdr) = DnCNN_wrapper(r, rvar, theta[7], reuse=True)
            xhat = tf.Print(xhat, [iter], "used denoiser 7")
            return (xhat, dxdr)

        def x_nl8(a=rstd,iter=iter,r=r,rvar=rvar,theta=theta):
            with tf.variable_scope("Adaptive_NL" + str(8)) as scope:
                (xhat, dxdr) = DnCNN_wrapper(r, rvar, theta[8], reuse=True)
            xhat = tf.Print(xhat, [iter], "used denoiser 8")
            return (xhat, dxdr)

        rstd=tf.Print(rstd,[rstd],"rstd =")
        NL_0 = tf.less_equal(rstd, 10.)
        NL_1 = tf.logical_and(tf.less(10., rstd), tf.less_equal(rstd, 20.))
        NL_2 = tf.logical_and(tf.less(20., rstd), tf.less_equal(rstd, 40.))
        NL_3 = tf.logical_and(tf.less(40., rstd), tf.less_equal(rstd, 60.))
        NL_4 = tf.logical_and(tf.less(60., rstd), tf.less_equal(rstd, 80.))
        NL_5 = tf.logical_and(tf.less(80., rstd), tf.less_equal(rstd, 100.))
        NL_6 = tf.logical_and(tf.less(100., rstd), tf.less_equal(rstd, 150.))
        NL_7 = tf.logical_and(tf.less(150., rstd), tf.less_equal(rstd, 300.))
        predicates = {NL_0:  x_nl0, NL_1:  x_nl1, NL_2:  x_nl2, NL_3:  x_nl3, NL_4:  x_nl4, NL_5:  x_nl5, NL_6:  x_nl6, NL_7:  x_nl7}
        default =  x_nl8
        (xhat,dxdr) = tf.case(predicates,default,exclusive=True)
        xhat = tf.reshape(xhat, shape=[n, BATCH_SIZE])
        dxdr = tf.reshape(dxdr, shape=[1, BATCH_SIZE])
    else:
        with tf.variable_scope("Iter" + str(iter)):  # Ensure correct normalization variables are used at this iteration
            (xhat, dxdr) = DnCNN_wrapper(r, rvar, theta[iter], reuse=True)
    return (xhat, dxdr)

## Denoiser Wrapper that computes divergence
def DnCNN_wrapper(r,rvar,theta_thislayer,reuse):
    """
    Call a black-box denoiser and compute a Monte Carlo estimate of dx/dr
    """
    xhat=DnCNN(r,rvar,theta_thislayer,reuse=reuse)
    r_abs = tf.abs(r, name=None)
    epsilon = tf.maximum(.001 * tf.reduce_max(r_abs, axis=0),.00001)
    eta=tf.random_normal(shape=r.get_shape(),dtype=tf.float32)
    if is_complex:
        r_perturbed = r + tf.complex(tf.multiply(eta, epsilon),tf.zeros([n,BATCH_SIZE],dtype=tf.float32))
    else:
        r_perturbed = r + tf.multiply(eta, epsilon)
    xhat_perturbed=DnCNN(r_perturbed,rvar,theta_thislayer,reuse=True)#Avoid computing gradients wrt this use of theta_thislayer
    eta_dx=tf.multiply(eta,xhat_perturbed-xhat)#Want element-wise multiplication
    mean_eta_dx=tf.reduce_mean(eta_dx,axis=0)
    dxdrMC=tf.divide(mean_eta_dx,epsilon)
    dxdrMC=tf.stop_gradient(dxdrMC)#With long networks propagating wrt the MC estimates caused divergence
    return(xhat,dxdrMC)

## Create Denoiser Model
def DnCNN(r,rvar, theta_thislayer,reuse):
    ##r is n x batch_size, where in this case n would be height_img*width_img*channel_img
    #rvar is unused within DnCNN. It may have been used to select which sets of weights and biases to use.
    weights=theta_thislayer[0]
    biases=theta_thislayer[1]

    if is_complex:
        r=tf.real(r)
    r=tf.transpose(r)
    orig_Shape = tf.shape(r)
    shape4D = [-1, height_img, width_img, channel_img]
    r = tf.reshape(r, shape4D)  # reshaping input
    layers = [None] * n_DnCNN_layers

    #############  First Layer ###############
    # Conv + Relu
    conv_out = tf.nn.conv2d(r, weights[0], strides=[1, 1, 1, 1], padding='SAME',data_format='NHWC') + biases[0]#NCHW works faster on nvidia hardware, however I only perform this type of conovlution once so performance difference will be negligible
    layers[0] = tf.nn.relu(conv_out)

    #############  2nd to 2nd to Last Layer ###############
    # Conv + BN + Relu
    for i in range(1,n_DnCNN_layers-1):
        with tf.variable_scope("l" + str(i)):#Added so that batch_normalization/moving_variance, moving_mean, and beta would all be placed in the l1/... l2/... respectively.
            #To inspect current variable names use vars=tf.get_collection(tf.GraphKeys.GLOBAL_VARIABLES), and vars[index].name
            conv_out  = tf.nn.conv2d(layers[i-1], weights[i], strides=[1, 1, 1, 1], padding='SAME') + biases[i]
            #batch_out = tf.layers.batch_normalization(inputs=conv_out, center=True, scale=False, training=training, trainable=False, name='BN',reuse=reuse)
            batch_out = tf.layers.batch_normalization(inputs=conv_out, center=True, scale=False, training=False, trainable=False, name='BN', reuse=reuse)#The documentation says training should be true for training and false for inference. In practice I found setting things this way killed performance
            layers[i] = tf.nn.relu(batch_out)

    #############  Last Layer ###############
    # Conv
    layers[n_DnCNN_layers-1]  = tf.nn.conv2d(layers[n_DnCNN_layers-2], weights[n_DnCNN_layers-1], strides=[1, 1, 1, 1], padding='SAME') + biases[n_DnCNN_layers-1]

    x_hat = r-layers[n_DnCNN_layers-1]
    x_hat = tf.transpose(tf.reshape(x_hat,orig_Shape))
    return x_hat

## Create training data from images, with tf and function handles
def GenerateNoisyCSData_handles(x,A_handle,sigma_w,A_params):
    y = A_handle(A_params,x)
    y = AddNoise(y,sigma_w)
    return y

## Create training data from images, with tf
def GenerateNoisyCSData(x,A,sigma_w):
    y = tf.matmul(A,x)
    y = AddNoise(y,sigma_w)
    return y

## Create training data from images, with tf
def AddNoise(clean,sigma):
    if is_complex:
        noise_vec = sigma/np.sqrt(2) *( tf.complex(tf.random_normal(shape=clean.shape, dtype=tf.float32),tf.random_normal(shape=clean.shape, dtype=tf.float32)))
    else:
        noise_vec=sigma*tf.random_normal(shape=clean.shape,dtype=tf.float32)
    noisy=clean+noise_vec
    return noisy

## Create training data from images, with numpy
def GenerateNoisyCSData_np(x,A,sigma_w):
    y = np.matmul(A,x)
    y = AddNoise_np(y,sigma_w)
    return y

## Create training data from images, with numpy
def AddNoise_np(clean,sigma):
    noise_vec=np.random.randn(clean.size)
    noise_vec = sigma * np.reshape(noise_vec, newshape=clean.shape)
    noisy=clean+noise_vec
    return noisy

##Create a string that generates filenames. Ensures consitency between functions
def GenLDAMPFilename(alg,tie_weights,LayerbyLayer,n_DAMP_layer_override=None,sampling_rate_override=None):
    if n_DAMP_layer_override:
        n_DAMP_layers_save=n_DAMP_layer_override
    else:
        n_DAMP_layers_save=n_DAMP_layers
    if sampling_rate_override:
        sampling_rate_save=sampling_rate_override
    else:
        sampling_rate_save=sampling_rate
    filename = "./saved_models/LDAMP/"+alg+"_" + str(n_DnCNN_layers) + "DnCNNL_" + str(int(n_DAMP_layers_save)) + "DAMPL_Tie"+str(tie_weights)+"_LbyL"+str(LayerbyLayer)+"_SR" +str(int(sampling_rate_save*100))
    return filename

##Create a string that generates filenames. Ensures consitency between functions
def GenDnCNNFilename(sigma_w_min,sigma_w_max):
    filename="./saved_models/DnCNN/DnCNN_" + str(n_DnCNN_layers) + "L_sigmaMin" + str(int(255.*sigma_w_min))+"_sigmaMax" + str(int(255.*sigma_w_max))
    return filename

## Count the total number of learnable parameters
def CountParameters():
    total_parameters = 0
    for variable in tf.trainable_variables():
        shape = variable.get_shape()   #[3,3,1,64]
        variable_parameters = 1
        for dim in shape:
            variable_parameters *= dim.value
        total_parameters += variable_parameters  #权重的总个数3*3*64=576
    print('Total number of parameters: ')  #518209
    print(total_parameters)