function grad2 = grad2(F,N,omega,M,Fs,alpha)
%GRAD2 Compute the second part of the gradient
% Entries:
%   - F: the Ideal TF estimation
%   - N: length of the time vector
%   - omega: frequency vector
%   - M: length of the frequency vector
%   - Fs: Sampling Frequency
%   - alpha: chirp factor

dtF = deriv_t(F, Fs, N, M );
dfF = deriv_f(F, Fs, N, M);

if (norm(alpha)==0)
    grad2 = (1/(M-1))*(-deriv_t(dtF, Fs, N, M ) + ...
        4i*pi*repmat(omega',1,N).*dtF + ...
        (4*pi^2*repmat(omega',1,N).^2).*F);
    
    
else
    grad2 = (1/(M-1))*( -deriv_t(dtF, Fs, N, M ) + ...
        4i*pi*repmat(omega',1,N).*dtF - ...
        deriv_t( bsxfun(@times,alpha,dfF), Fs, N, M ) + ...
        (4*pi^2*repmat(omega',1,N).^2).*F  - ...
        bsxfun(@times,alpha,deriv_f(dtF, Fs, N, M)) + ...
        4i*pi*bsxfun(@times,alpha,repmat(omega',1,N).*dfF) +...
        2i*pi*bsxfun(@times,alpha,dfF) - ...
        bsxfun(@times,alpha.^2,deriv_f(dfF, Fs, N, M)) );
    
end


