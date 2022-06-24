function [my_H,my_hs]=my_conv_H(fs,ph,Fs,tw,refresh_rate,erp_period)

sig_len=floor(tw*Fs);
t=[0:sig_len-1]/Fs;
h0=cos(2*pi*fs*t+ph)+1;
sel_idx=round(Fs/refresh_rate*[0:refresh_rate*tw-1])+1;
h_val=h0(1);
cn=1;
for m=1:length(h0)
    if (m==sel_idx(cn))
        h_val=h0(m);
        if cn>=length(sel_idx)
        else
            cn=cn+1;
        end
    else
    end
    h(m)=h_val;
end
hs=square(2*pi*fs*t+ph,20)+1;
count_thres=floor(0.9*Fs/fs);
count=count_thres+1;
for m=1:length(hs)
    if (hs(m)==0)
        count=count_thres+1;
    else
        if count>=count_thres
            hs(m)=h(m);
            count=1;
        else
            count=count+1;
            hs(m)=0;
        end
    end
end

erp_len = round(erp_period*Fs);

for k=1:erp_len
    H(k,k:k+sig_len-1)=hs;
end

H=H(:,1:sig_len);
my_H=H;
my_hs=hs;