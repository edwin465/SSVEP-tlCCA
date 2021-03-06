% My reference:
% E:\Dropbox\Disk\BCI competition 2019\ssvep-training-local-system-for-matlab\my\paper_ssvep_acc_dataset_transfer_als_20190930.m
% E:\Dropbox\Disk\BCI competition 2019\ssvep-training-local-system-for-matlab\my\paper_data_transfer_result_20190930.xlsx


% This code is prepared by Chi Man Wong (chiman465@gmail.com)
% Date: 22 June 2022
% if you use this code for a publication, please cite the following paper
% @article{wong2021transferring,
%   title={Transferring subject-specific knowledge across stimulus frequencies in SSVEP-based BCIs},
%   author={Wong, Chi Man and Wang, Ze and Rosa, Agostinho C and Chen, CL Philip and Jung, Tzyy-Ping and Hu, Yong and Wan, Feng},
%   journal={IEEE Transactions on Automation Science and Engineering},
%   volume={18},
%   number={2},
%   pages={552--563},
%   year={2021},
%   publisher={IEEE}
% }

clear all;
close all;

addpath('..\mytoolbox\');
Fs=250; % sample rate

dataset_no=2; % 1: TH benchmark dataset, 2: BETA dataset, 3: BCI competition 2019 dataset
transfer_type=2;
% 1: Source: 8.0, 8.4, 8.8, ..., 15.6 Hz, Target: 8.2, 8.6, 9.0, ..., 15.8 Hz
% 2: Source: 8.2, 8.6, 9.0, ..., 15.8 Hz, Target: 8.0, 8.4, 8.8, ..., 15.6 Hz

if dataset_no==1
    str_dir='..\Tsinghua dataset 2016\';
    num_of_signal_templates=5;          % for mscca (1<=num_of_signal_templates<=20)
    num_of_signal_templates2=2;         % for ms-etrca (1<=num_of_signal_templates<=20)
    num_of_wn=4;                        % for TDCA
    num_of_k=8;                         % for TDCA
    num_of_delay=6;                     % for TDCA
    latencyDelay = round(0.14*Fs);      % latency
    num_of_subj=35;                     % Number of subjects (35 if you have the benchmark dataset)
    ch_used=[48 54 55 56 57 58 61 62 63]; % Pz, PO5, PO3, POz, PO4, PO6, O1,Oz, O2 (in SSVEP benchmark dataset)
    num_of_trials=5;                    % Number of training trials (1<=num_of_trials<=5)
    pha_val=[0 0.5 1 1.5 0 0.5 1 1.5 0 0.5 1 1.5 0 0.5 1 1.5 0 0.5 1 1.5 ...
        0 0.5 1 1.5 0 0.5 1 1.5 0 0.5 1 1.5 0 0.5 1 1.5 0 0.5 1 1.5]*pi;
    sti_f=[8.0:1:15.0, 8.2:1:15.2,8.4:1:15.4,8.6:1:15.6,8.8:1:15.8];
    n_sti=length(sti_f);                     % number of stimulus frequencies
    [~,target_order]=sort(sti_f);
    sti_f=sti_f(target_order);
    
    
elseif dataset_no==2
    str_dir='..\BETA SSVEP dataset\';
    num_of_signal_templates=5;          % for mscca (1<=num_of_signal_templates<=20)
    num_of_signal_templates2=2;         % for ms-etrca (1<=num_of_signal_templates<=20)
    num_of_wn=4;                        % for TDCA
    num_of_k=9;                         % for TDCA
    num_of_delay=4;                     % for TDCA
    latencyDelay = round(0.13*Fs);      % latency
    num_of_subj=70;
    ch_used=[48 54 55 56 57 58 61 62 63]; % Pz, PO5, PO3, POz, PO4, PO6, O1,Oz, O2 (in BETA dataset)
    num_of_trials=3;                    % Number of training trials (1<=num_of_trials<=3)
    pha_val=[0 0.5 1 1.5 0 0.5 1 1.5 0 0.5 1 1.5 0 0.5 1 1.5 0 0.5 1 1.5 ...
        0 0.5 1 1.5 0 0.5 1 1.5 0 0.5 1 1.5 0 0.5 1 1.5 0 0.5 1 1.5]*pi;
    sti_f=[8.6:0.2:15.8,8.0 8.2 8.4];
    n_sti=length(sti_f);                     % number of stimulus frequencies
    [~,target_order]=sort(sti_f);
    sti_f=sti_f(target_order);
elseif dataset_no==3
    str_dir='..\SSVEP competition 2019\';
    num_of_signal_templates=5;          % for mscca (1<=num_of_signal_templates<=20)
    num_of_signal_templates2=5;         % for ms-etrca (1<=num_of_signal_templates<=20)
    ch_used=[43 53 51 50 52 54 58 57 59]; % Pz, PO5, PO3, POz, PO4, PO6, O1,Oz, O2 (in Competition dataset)
    num_of_trials=2;                    % Number of training trials (1<=num_of_trials<=2)
    num_of_subj=60;
    num_of_wn=4;                        % for TDCA
    num_of_k=9;                         % for TDCA
    num_of_delay=4;                     % for TDCA
    latencyDelay = round(0.13*Fs);      % latency
    
    pha_val=[0 0.5 1 1.5 0 0.5 1 1.5 0 0.5 1 1.5 0 0.5 1 1.5 0 0.5 1 1.5 ...
        0 0.5 1 1.5 0 0.5 1 1.5 0 0.5 1 1.5 0 0.5 1 1.5 0 0.5 1 1.5]*pi;
    
    sti_f=[8.0:0.2:15.8];
    n_sti=length(sti_f);                     % number of stimulus frequencies
    [~,target_order]=sort(sti_f);
    sti_f=sti_f(target_order);
end

if transfer_type==1
    source_freq_idx=[1:2:length(sti_f)];
    target_freq_idx=[2:2:length(sti_f)];
elseif transfer_type==2
    source_freq_idx=[2:2:length(sti_f)];
    target_freq_idx=[1:2:length(sti_f)];
else
end
sti_f_source = sti_f(source_freq_idx);
pha_val_source = pha_val(source_freq_idx);
sti_f_target = sti_f(target_freq_idx);
pha_val_target = pha_val(target_freq_idx);


num_of_harmonics=5;                 % for all cca-based methods

num_of_r=4;                         % for ecca
num_of_subbands=5;                  % for filter bank analysis
FB_coef0=[1:num_of_subbands].^(-1.25)+0.25; % for filter bank analysis

% time-window length (min_length:delta_t:max_length)
min_length=0.3;
delta_t=0.1;
max_length=1.2;                     % [min_length:delta_t:max_length]

enable_bit=[1 1 1 1 1 1];           % Select the algorithms: bit 1: eCCA, bit 2: ms-eCCA, bit 3: eTRCA, bit 4: ms-eTRCA, bit 5: TDCA,  bit 6: tlCCA, e.g., enable_bit=[1 1 1 1 1 1]; -> select all algorithms
is_center_std=0;                    % 0: without , 1: with (zero mean, and unity standard deviation)

% Chebyshev Type I filter design
for k=1:num_of_subbands
    Wp = [(8*k)/(Fs/2) 90/(Fs/2)];
    Ws = [(8*k-2)/(Fs/2) 100/(Fs/2)];
    [N,Wn] = cheb1ord(Wp,Ws,3,40);
    [subband_signal(k).bpB,subband_signal(k).bpA] = cheby1(N,0.5,Wn);
end
%notch
Fo = 50;
Q = 35;
BW = (Fo/(Fs/2))/Q;

[notchB,notchA] = iircomb(Fs/Fo,BW,'notch');
seed = RandStream('mt19937ar','Seed','shuffle');
for sn=1:num_of_subj
    tic
    if dataset_no==1
        load(strcat(str_dir,'S',num2str(sn),'.mat'));
        eeg=data(ch_used,floor(0.5*Fs)+1:floor(0.5*Fs+latencyDelay)+2*Fs,:,:);
    elseif dataset_no==2
        load([str_dir 'S' num2str(sn) '.mat']);
        eegdata=data.EEG;
        data = permute(eegdata,[1 2 4 3]);
        eeg=data(ch_used,floor(0.5*Fs)+1:floor(0.5*Fs+latencyDelay)+2*Fs,:,:);
    elseif dataset_no==3
        load([str_dir 'S' num2str(sn) '.mat']);
        eeg=data(ch_used,1:floor(latencyDelay)+2*Fs,:,:);
    end
    
    
    [d1_,d2_,d3_,d4_]=size(eeg);
    d1=d3_;d2=d4_;d3=d1_;d4=d2_;
    %     no_of_class=d1;
    n_ch=d3;
    % d1: num of stimuli
    % d2: num of trials
    % d3: num of channels
    % d4: num of sampling points
    for i=1:1:d1
        for j=1:1:d2
            y0=reshape(eeg(:,:,i,j),d3,d4);
            y = filtfilt(notchB, notchA, y0.'); %notch
            y = y.';
            for sub_band=1:num_of_subbands
                
                for ch_no=1:d3
                    tmp2=filtfilt(subband_signal(sub_band).bpB,subband_signal(sub_band).bpA,y(ch_no,:));
                    y_sb(ch_no,:) = tmp2(latencyDelay+1:latencyDelay+2*Fs);
                end
                
                subband_signal(sub_band).SSVEPdata(:,:,j,i)=reshape(y_sb,d3,length(y_sb),1,1);
            end
            
        end
    end
    
    clear eeg
    %% Initialization
    
    TW=min_length:delta_t:max_length;
    TW_p=round(TW*Fs);
    n_run=d2;                                % number of used runs
    
    for sub_band=1:num_of_subbands
        subband_signal(sub_band).SSVEPdata=subband_signal(sub_band).SSVEPdata(:,:,:,target_order); % To sort the orders of the data as 8.0, 8.2, 8.4, ..., 15.8 Hz
    end
    
    % Divide into two sets: source and target dataset
    no_of_class = length(source_freq_idx);
    for k=1:num_of_subbands
        subband_signal(k).SSVEPdata_source=subband_signal(k).SSVEPdata(:,:,:,source_freq_idx);
        subband_signal(k).SSVEPdata_target=subband_signal(k).SSVEPdata(:,:,:,target_freq_idx);
    end
    
    FB_coef=FB_coef0'*ones(1,length(sti_f_target));
    n_correct=zeros(length(TW),9); % Count how many correct detection
    
    for tw_length=1:length(TW)
        clear Xa Xa_train
        sig_len=TW_p(tw_length);
        
        
        dataLength = 2*Fs;
        % Transfer learning stage:
        for i = length(sti_f_source):-1:1
            testFres = sti_f_source(i) * (1:num_of_harmonics)';
            
            t = 0:1/Fs:1/Fs * (dataLength-1);
            ref_source{i} = [cos( 2 * pi * testFres * t +pha_val_source(i)* (1:num_of_harmonics)');...
                sin( 2 * pi * testFres * t+pha_val_source(i)* (1:num_of_harmonics)')];
        end
        
        for sub_band=1:num_of_subbands
            subband_signal(sub_band).templates_transfer=zeros(sig_len,no_of_class);
            subband_signal(sub_band).templates_source = squeeze(mean(subband_signal(sub_band).SSVEPdata_source,3));
            
            % Find the transfered spatial filters
            for stim_no=1:length(sti_f_source)
                d0=floor(num_of_signal_templates/2);
                d1=length(sti_f_source);
                if stim_no<=d0
                    template_st=1;
                    template_ed=num_of_signal_templates;
                elseif ((stim_no>d0) && stim_no<(d1-d0+1))
                    template_st=stim_no-d0;
                    template_ed=stim_no+(num_of_signal_templates-d0-1);
                else
                    template_st=(d1-num_of_signal_templates+1);
                    template_ed=d1;
                end
                template_idx=[template_st:template_ed];
                mscca_X=[];
                mscca_Y=[];
                for m=1:num_of_signal_templates
                    mm=template_idx(m);
                    tmp=subband_signal(sub_band).templates_source(:,:,mm);
                    if (is_center_std==1)
                        tmp=tmp-mean(tmp,2)*ones(1,length(tmp));
                        tmp=tmp./(std(tmp')'*ones(1,length(tmp)));
                    end
                    mscca_X=[mscca_X,tmp];
                    mscca_Y=[mscca_Y,ref_source{mm}];
                end
                [A,B] = canoncorr(mscca_X',mscca_Y');
                subband_signal(sub_band).Wx_source(:,stim_no)=A(:,1);
                subband_signal(sub_band).Wy_source(:,stim_no)=B(:,1);
                
            end
            
            % Find the transfered spatial filters and transfered templates
            for stim_no=1:length(sti_f_source)
                % target frequency and phase
                fs=sti_f_target(stim_no);
                ph=pha_val_target(stim_no);
                
                y_tmp=[];
                h_tmp=[];
                
                frequency_period=1.05*1/sti_f_source(stim_no);
                % source frequency and phase
                fs_0=sti_f_source(stim_no);
                ph_0=pha_val_source(stim_no);
                st=1;
                ssvep0=subband_signal(sub_band).templates_source(:,st:st+dataLength-1,stim_no);                
                [H0,h0]=my_conv_H(fs_0,ph_0,Fs,dataLength/Fs,60,frequency_period);                
                h_len=size(H0,1);
                
                % target frequency and phase
                fs_target=sti_f_target(stim_no);
                ph_target=pha_val_target(stim_no);
                
                % Alternating Least Square (Find the impulse response and the spatial filter
                % simultaneously
                w0_old=randn(1,n_ch);
                x_hat_old=w0_old*ssvep0*H0'*inv(H0*H0');
                e_old=norm(w0_old*ssvep0-x_hat_old*H0);
                iter_err=100;
                iter=1;
                while (iter_err(iter)>0.0001 && iter<200)
                    w0_new=x_hat_old*H0*ssvep0'*inv(ssvep0*ssvep0');
                    x_hat_new=w0_new*ssvep0*H0'*inv(H0*H0');
                    e_new=norm(w0_new*ssvep0-x_hat_new*H0);
                    iter=iter+1;
                    iter_err(iter)=abs(e_old-e_new);
                    w0_old=w0_new;
                    w0_old=w0_old/std(w0_old);
                    x_hat_old=x_hat_new;
                    x_hat_old=x_hat_old/std(x_hat_old);
                    e_old=e_new;
                end
                x_hat_=x_hat_new;
                x_hat=x_hat_(1:h_len);
                
                % Reconstructed SSVEP
                y_re=x_hat*H0;
                y_=w0_new*ssvep0;
                y_re(:,1:length(find(y_re==0)))=0.8*y_re(:,Fs+1:Fs+length(find(y_re==0)));
                
                r=corrcoef(y_,y_re);     % the similarity between the reconstructed and original ssvep
                ycor(sn,stim_no)=abs(r(1,2));
                
                % Transferred spatial filter
                subband_signal(sub_band).Wx_transfer(:,stim_no)=w0_new';
                                
                [H_target,h_target]=my_conv_H(fs_target,ph_target,Fs,dataLength/Fs,60,frequency_period);
                
                y_hat=x_hat*H_target;
                y_hat(1:length(find(y_hat==0)))=0.8*y_hat(Fs+1:Fs+length(find(y_hat==0)));
                % Transferred SSVEP template
                subband_signal(sub_band).templates_transfer(st:st+sig_len-1,stim_no)=y_hat(1:sig_len);
                
                clear H H_tr
            end
            
        end
        
        
        % Sine-cosine reference signal for training and testing stage
        for i = length(sti_f_target):-1:1
            
            testFres = sti_f_target(i) * (1:num_of_harmonics)';
            t = 0:1/Fs:1/Fs * (sig_len-1);
            
            ref_target{i} = [cos( 2 * pi * testFres * t +pha_val_target(i)* (1:num_of_harmonics)');...
                sin( 2 * pi * testFres * t+pha_val_target(i)* (1:num_of_harmonics)')];
        end
                
        seq_0=zeros(d2,num_of_trials);
        for run=1:d2
            %         % leave-one-run-out cross-validation
            if (num_of_trials==1)
                seq1=run;
            elseif (num_of_trials==d2-1)
                seq1=[1:n_run];
                seq1(run)=[];
            else
                % leave-one-run-out cross-validation
                % Randomly select the trials for training
                isOK=0;
                while (isOK==0)
                    seq=randperm(seed,d2);
                    seq1=seq(1:num_of_trials);
                    seq1=sort(seq1);
                    if isempty(find(sum((seq1'*ones(1,d2)-seq_0').^2)==0))
                        isOK=1;
                    end
                end
                
            end
            idx_traindata=seq1; % index of the training trials
            idx_testdata=1:n_run; % index of the testing trials
            idx_testdata(seq1)=[];
            
            for i=1:no_of_class
                for k=1:num_of_subbands
                    if length(idx_traindata)>1
                        subband_signal(k).templates_target(i,:,:)=mean(subband_signal(k).SSVEPdata_target(:,:,idx_traindata,i),3);
                    else
                        subband_signal(k).templates_target(i,:,:)=subband_signal(k).SSVEPdata_target(:,:,idx_traindata,i);
                    end
                end
            end
            
            % Training stage:
            % For TDCA
            if enable_bit(5)==1
                for sub_band=1:num_of_subbands
                    for j=1:no_of_class
                        Ref=ref_signal_nh(sti_f_target(j),Fs,0,sig_len,num_of_harmonics);
                        [Q_ref1,R_ref1]=qr(Ref',0);
                        P=Q_ref1*Q_ref1';
                        for train_no=1:length(idx_traindata)
                            traindata_1a=[];
                            for dn=1:num_of_delay
                                traindata=reshape(subband_signal(sub_band).SSVEPdata_target(:,[dn:sig_len+dn-1],idx_traindata(train_no),j),d3,sig_len);
                                if (is_center_std==1)
                                    traindata=traindata-mean(traindata,2)*ones(1,length(traindata));
                                    traindata=traindata./(std(traindata')'*ones(1,length(traindata)));
                                end
                                traindata_1a=[traindata_1a;traindata];
                            end
                            traindata_1a_P=traindata_1a*P;
                            if (is_center_std==1)
                                traindata_1a_P=traindata_1a_P-mean(traindata_1a_P,2)*ones(1,length(traindata_1a_P));
                                traindata_1a_P=traindata_1a_P./(std(traindata_1a_P')'*ones(1,length(traindata_1a_P)));
                            end
                            Xa(:,:,train_no,j)=[traindata_1a traindata_1a_P];
                        end
                        Xa_train(:,:,j,sub_band)=mean(Xa(:,:,:,j),3);
                    end
                    
                    Sb=zeros(num_of_delay*d3);
                    Sw=zeros(num_of_delay*d3);
                    for j=1:no_of_class
                        
                        for train_no=1:length(idx_traindata)
                            if length(idx_traindata)==1
                                X_tmp=Xa(:,:,train_no,j);
                            else
                                X_tmp=Xa(:,:,train_no,j)-mean(Xa(:,:,:,j),3);
                            end
                            Sw=Sw+X_tmp*X_tmp'/length(idx_traindata);
                        end
                        
                        tmp=mean(Xa(:,:,:,j),3)-mean(mean(Xa,4),3);
                        Sb=Sb+tmp*tmp'/no_of_class;
                    end
                    
                    [eig_v1,eig_d1]=eig(Sw\Sb);
                    [eig_val,sort_idx]=sort(diag(eig_d1),'descend');
                    eig_vec=eig_v1(:,sort_idx(1:num_of_k));
                    subband_signal(sub_band).Wx_TDCA=eig_vec;
                end
            end
            % For ms-eCCA
            % =============== ms-eCCA ===============
            if (enable_bit(2)==1)
                for sub_band=1:num_of_subbands
                    for j=1:length(sti_f_target)
                        % find the indices of neighboring templates
                        d0=floor(num_of_signal_templates/2);
                        if j<=d0
                            template_st=1;
                            template_ed=num_of_signal_templates;
                        elseif ((j>d0) && j<(d1-d0+1))
                            template_st=j-d0;
                            template_ed=j+(num_of_signal_templates-d0-1);
                        else
                            template_st=(d1-num_of_signal_templates+1);
                            template_ed=d1;
                        end
                        mscca_template=[];
                        mscca_ref=[];
                        template_seq=[template_st:template_ed];
                        
                        % Concatenation of the templates (or sine-cosine references)
                        for n_temp=1:num_of_signal_templates
                            template0=reshape(subband_signal(sub_band).templates_target(template_seq(n_temp),:,1:sig_len),d3,sig_len);
                            if (is_center_std==1)
                                template0=template0-mean(template0,2)*ones(1,length(template0));
                                template0=template0./(std(template0')'*ones(1,length(template0)));
                            end
                            %                                         ref0=ref_signal_nh(sti_f(template_seq(n_temp)),Fs,phf_12(sn,1,template_seq(n_temp)),sig_len,num_of_harmonics);
                            ref0=ref_target{template_seq(n_temp)};
                            mscca_template=[mscca_template;template0'];
                            mscca_ref=[mscca_ref;ref0'];
                        end
                        % ========mscca spatial filter=====
                        [Wx1,Wy1,cr1]=canoncorr(mscca_template,mscca_ref(:,1:end));
                        %                     spatial_filter1(sub_band,j).wx1=Wx1(:,1)';
                        %                     spatial_filter1(sub_band,j).wy1=Wy1(:,1)';
                        subband_signal(sub_band).Wx_mseCCA(:,j)=Wx1(:,1);
                        subband_signal(sub_band).Wy_mseCCA(:,j)=Wy1(:,1);
                    end
                end
            end
            % for eTRCA
            if (enable_bit(3)==1)
                
                if (num_of_trials==1)
                    % num_of_trials cannot be less than 2
                    % in TRCA
                    %                     TRCAR(sub_band,j)=0;
                else
                    for sub_band=1:num_of_subbands
                        Wz=[];
                        for jj=1:length(sti_f_target)
                            trca_X2=[];
                            trca_X1=zeros(d3,sig_len);
                            for tr=1:num_of_trials
                                X0=reshape(subband_signal(sub_band).SSVEPdata_target(:,1:sig_len,idx_traindata(tr),jj),d3,sig_len);
                                if (is_center_std==1)
                                    X0=X0-mean(X0,2)*ones(1,length(X0));
                                    X0=X0./(std(X0')'*ones(1,length(X0)));
                                end
                                trca_X1=trca_X1+X0;
                                trca_X2=[trca_X2;X0'];
                            end
                            S=trca_X1*trca_X1'-trca_X2'*trca_X2;
                            Q=trca_X2'*trca_X2;
                            [eig_v1,eig_d1]=eig(Q\S);
                            [eig_val,sort_idx]=sort(diag(eig_d1),'descend');
                            eig_vec=eig_v1(:,sort_idx);
                            Wz=[Wz eig_vec(:,1)];
                        end
                        subband_signal(sub_band).Wx_eTRCA=Wz;
                    end
                end
            end
            % For ms-eTRCA
            %===============ms-eTRCA==================
            if (enable_bit(4)==1)
                if (num_of_trials==1)
                    %                     % num_of_trials cannot be less than 2
                    %                     % in eTRCA
                else
                    for sub_band=1:num_of_subbands
                        Wz=[];
                        
                        for my_j=1:no_of_class
                            d0=floor(num_of_signal_templates2/2);
                            if my_j<=d0
                                template_st=1;
                                template_ed=num_of_signal_templates2;
                            elseif ((my_j>d0) && my_j<(d1-d0+1))
                                template_st=my_j-d0;
                                template_ed=my_j+(num_of_signal_templates2-d0-1);
                            else
                                template_st=(d1-num_of_signal_templates2+1);
                                template_ed=d1;
                            end
                            template_seq=[template_st:template_ed];
                            mstrca_X1=[];
                            mstrca_X2=[];
                            
                            for n_temp=1:num_of_signal_templates2
                                jj=template_seq(n_temp);
                                trca_X2=[];
                                trca_X1=zeros(d3,sig_len);
                                template2=zeros(d3,sig_len);
                                
                                for tr=1:num_of_trials
                                    X0=reshape(subband_signal(sub_band).SSVEPdata_target(:,1:sig_len,idx_traindata(tr),jj),d3,sig_len);
                                    if (is_center_std==1)
                                        X0=X0-mean(X0,2)*ones(1,length(X0));
                                        X0=X0./(std(X0')'*ones(1,length(X0)));
                                    end
                                    trca_X2=[trca_X2;X0'];
                                    trca_X1=trca_X1+X0;
                                end
                                mstrca_X1=[mstrca_X1 trca_X1];
                                mstrca_X2=[mstrca_X2 trca_X2'];
                            end
                            S=mstrca_X1*mstrca_X1'-mstrca_X2*mstrca_X2';
                            Q=mstrca_X2*mstrca_X2';
                            [eig_v1,eig_d1]=eig(Q\S);
                            [eig_val,sort_idx]=sort(diag(eig_d1),'descend');
                            eig_vec=eig_v1(:,sort_idx);
                            Wz=[Wz eig_vec(:,1)];
                        end
                        subband_signal(sub_band).Wx_mseTRCA=Wz;
                    end
                end
            end
            %                     end
            
            % Testing stage
            for run_test=1:length(idx_testdata)
                
                
                
                test_signal=zeros(d3,sig_len);
                fprintf('Testing TW %fs, No.crossvalidation %d \n',TW(tw_length),idx_testdata(run_test));
                
                
                for i=1:no_of_class
                    
                    
                    for sub_band=1:num_of_subbands
                        test_signal=subband_signal(sub_band).SSVEPdata_target(:,1:TW_p(tw_length),idx_testdata(run_test),i);
                        if (is_center_std==1)
                            test_signal=test_signal-mean(test_signal,2)*ones(1,length(test_signal));
                            test_signal=test_signal./(std(test_signal')'*ones(1,length(test_signal)));
                        end
                        for j=1:no_of_class
                            template=reshape(subband_signal(sub_band).templates_target(j,:,[1:sig_len]),d3,sig_len);
                            if (is_center_std==1)
                                template=template-mean(template,2)*ones(1,length(template));
                                template=template./(std(template')'*ones(1,length(template)));
                            end
                            
                            % Generate the sine-cosine reference signal
                            ref1=ref_target{j};
                            
                            % ================ eCCA ===============
                            if (enable_bit(1)==1)
                                [ecca_r1,CR(sub_band,j),itR(sub_band,j),CCAR(sub_band,j)]=extendedCCA(test_signal,ref1,template,num_of_r);
                            else
                                CR(sub_band,j)=0;
                                itR(sub_band,j)=0;
                                CCAR(sub_band,j)=0;
                            end
                            
                            if (enable_bit(2)==1)
                                cr1=corrcoef((subband_signal(sub_band).Wx_mseCCA(:,j)'*test_signal)',(subband_signal(sub_band).Wy_mseCCA(:,j)'*ref1)');
                                cr2=corrcoef((subband_signal(sub_band).Wx_mseCCA(:,j)'*test_signal)',(subband_signal(sub_band).Wx_mseCCA(:,j)'*template)');
                                %
                                msccaR(sub_band,j)=sign(cr1(1,2))*cr1(1,2)^2+sign(cr2(1,2))*cr2(1,2)^2;
                            else
                                msccaR(sub_band,j)=0;
                            end
                            
                            %===============eTRCA==================
                            if (enable_bit(3)==1)
                                if (num_of_trials==1)
                                    % num_of_trials cannot be less than 2
                                    % in TRCA
                                    TRCAR(sub_band,j)=0;
                                else
                                    cr1=corrcoef(subband_signal(sub_band).Wx_eTRCA'*test_signal,subband_signal(sub_band).Wx_eTRCA'*template);
                                    TRCAR(sub_band,j)=cr1(1,2);
                                end
                            else
                                TRCAR(sub_band,j)=0;
                            end
                            %===============ms-eTRCA==================
                            if (enable_bit(4)==1)
                                if (num_of_trials==1)
                                    % num_of_trials cannot be less than 2
                                    % in eTRCA
                                    MSTRCAR(sub_band,j)=0;
                                    MSCCATRCAR(sub_band,j)=0;
                                else
                                    cr1=corrcoef(subband_signal(sub_band).Wx_mseTRCA'*test_signal,subband_signal(sub_band).Wx_mseTRCA'*template);
                                    MSTRCAR(sub_band,j)=cr1(1,2);
                                    
                                    if (enable_bit(2)==1)
                                        cr2=corrcoef((subband_signal(sub_band).Wx_mseCCA(:,j)'*test_signal)',(subband_signal(sub_band).Wy_mseCCA(:,j)'*ref1)');
                                        MSCCATRCAR(sub_band,j)=sign(cr1(1,2))*cr1(1,2)^2+sign(cr2(1,2))*cr2(1,2)^2;
                                    else
                                        MSCCATRCAR(sub_band,j)=0;
                                    end
                                end
                            else
                                MSTRCAR(sub_band,j)=0;
                                MSCCATRCAR(sub_band,j)=0;
                            end
                            %===============TDCA==================
                            if (enable_bit(5)==1)
                                if (num_of_trials==1)
                                    % num_of_trials cannot be less than 2
                                    TDCAR(sub_band,j)=0;
                                else
                                    test_signal_1a=[];
                                    for dn=1:num_of_delay
                                        z=[test_signal(:,dn:end) zeros(length(ch_used),dn-1)];
                                        test_signal_1a=[test_signal_1a;z];
                                    end
                                    
                                    Ref=ref_signal_nh(sti_f(j),Fs,0,sig_len,num_of_harmonics);
                                    [Q_ref1,R_ref1]=qr(Ref',0);
                                    P=Q_ref1*Q_ref1';
                                    test_signal_1a_P=test_signal_1a*P;
                                    Xb=[test_signal_1a test_signal_1a_P];
                                    W=subband_signal(sub_band).Wx_TDCA;
                                    TDCAR(sub_band,j)=corr2(W'*Xb,W'*Xa_train(:,:,j,sub_band));
                                    
                                end
                            else
                                TDCAR(sub_band,j)=0;
                            end
                            %===============tlCCA==================
                            if (enable_bit(6)==1)
                                
                                r1a=corrcoef((subband_signal(sub_band).Wx_source(:,j)'*test_signal)',(subband_signal(sub_band).Wy_source(:,j)'*ref1)');
                                r1b=corrcoef((subband_signal(sub_band).Wx_transfer(:,j)'*test_signal)',(subband_signal(sub_band).templates_transfer(:,j))');
                                [A1,B1,r]=canoncorr(test_signal'*subband_signal(sub_band).Wx_source(:,j),ref1');
                                TLCCAR(sub_band,j)=sign(r1a(1,2))*r1a(1,2)^2+sign(r1b(1,2))*r1b(1,2)^2+sign(r(1))*r(1)^2;
                                TLCCARR(sub_band,j)=sign(r1a(1,2))*r1a(1,2)^2+sign(r1b(1,2))*r1b(1,2)^2;
                            else
                                TLCCAR(sub_band,j)=0;
                                TLCCARR(sub_band,j)=0;
                            end
                            
                        end
                        
                        
                    end
                    
                    CCAR1=sum((CCAR).*FB_coef,1);
                    CR1=sum((CR).*FB_coef,1);
                    msccaR1=sum((msccaR).*FB_coef,1);
                    TRCAR1=sum((TRCAR).*FB_coef,1);
                    MSTRCAR1=sum((MSTRCAR).*FB_coef,1);
                    MSCCATRCAR1=sum((MSCCATRCAR).*FB_coef,1);
                    TDCAR1=sum((TDCAR).*FB_coef,1);
                    TLCCAR1=sum((TLCCAR).*FB_coef,1);
                    TLCCAR2=sum((TLCCARR).*FB_coef,1);
                    
                    [~,idx]=max(CCAR1);
                    if idx==i
                        n_correct(tw_length,1)=n_correct(tw_length,1)+1;
                    end
                    [~,idx]=max(CR1);
                    if idx==i
                        n_correct(tw_length,2)=n_correct(tw_length,2)+1;
                    end
                    [~,idx]=max(msccaR1);
                    if idx==i
                        n_correct(tw_length,3)=n_correct(tw_length,3)+1;
                    end
                    [~,idx]=max(TRCAR1);
                    if idx==i
                        n_correct(tw_length,4)=n_correct(tw_length,4)+1;
                    end
                    [~,idx]=max(MSTRCAR1);
                    if idx==i
                        n_correct(tw_length,5)=n_correct(tw_length,5)+1;
                    end
                    [~,idx]=max(MSCCATRCAR1);
                    if idx==i
                        n_correct(tw_length,6)=n_correct(tw_length,6)+1;
                    end
                    [~,idx]=max(TDCAR1);
                    if idx==i
                        n_correct(tw_length,7)=n_correct(tw_length,7)+1;
                    end
                    [~,idx]=max(TLCCAR1);
                    if idx==i
                        n_correct(tw_length,8)=n_correct(tw_length,8)+1;
                    end
                    [~,idx]=max(TLCCAR2);
                    if idx==i
                        n_correct(tw_length,9)=n_correct(tw_length,9)+1;
                    end
                end
                %             end
            end
            idx_train_run(run,:)=idx_traindata;
            idx_test_run(run,:)=idx_testdata;
            seq_0(run,:)=seq1;
        end
    end
    
    %% Save results
    toc
    accuracy=100*n_correct/no_of_class/n_run/length(idx_testdata)
    % column 1: CCA
    % column 2: eCCA
    % column 3: ms-eCCA
    % column 4: eTRCA
    % column 5: ms-eTRCA
    % column 6: ms-eCCA + ms-eTRCA
    % column 7: TDCA
    % column 8: tlCCA-1
    % column 9: tlCCA-2
    if dataset_no==1
        xlswrite('acc_file.xlsx',accuracy'/100,strcat('Sheet',num2str(sn)));
    else
        xlswrite('acc_file2.xlsx',accuracy'/100,strcat('Sheet',num2str(sn)));
    end
    disp(sn)
end


