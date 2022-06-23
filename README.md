# SSVEP-tlCCA
Matlab code of our IEEE TASE paper "Wong, C. M., Wang, Z., Rosa, A. C., Chen, C. P., Jung, T. P., Hu, Y., Wan, F. (2021). Transferring subject-specific knowledge across stimulus frequencies in SSVEP-based BCIs. IEEE Transactions on Automation Science and Engineering, 18(2), 552-563." 

In this project, we aim to transfer the subject-specific knowledge, e.g., `spatial filter` and `SSVEP template`, over different neighboring frequencies for SSVEP recognition. Then the subject's  calibration data corresponding to the old visual stimulation scheme can be re-used for the new visual stimulation scheme. This means that the subject does not need to participate in a new calibration session while the stimulation frequencies are changed. For example, in the old visual stimulation scheme, the stimulus frequencies are 8.0Hz, 8.4Hz, 8.8Hz, ..., 15.6Hz. In the new visual stimulation scheme, they are 8.2Hz, 8.6Hz, 9.0Hz, ..., 15.8Hz. 

In order to re-use the knowledge or data from the old visual stimulation scheme, here we have two assumptions: 
1) A subject's SSVEPs over different stimulus frequencies can be assigned a common spatial filter. 
2) A subject's SSVEPs over different stimulus frequencies share a common impulse response. 

The first assumption has been verified in many research studies, such as  
*[1] Nakanishi, M., et al. (2017). Enhancing detection of SSVEPs for a high-speed brain speller using task-related component analysis. IEEE Transactions on Biomedical Engineering, 65(1), 104-112.*  
*[2] Wong, C. M., et al. (2020). Learning across multi-stimulus enhances target recognition methods in SSVEP-based BCIs. Journal of neural engineering, 17(1), 016026.* .  
In ideal case, **the spatial filter is frequency-non-specific and subject-specific**.


The second assumption comes from the superposition theory as mentioned in *Capilla, A., et al. (2011). Steady-state visual evoked potentials can be explained by temporal superposition of transient event-related responses. PloS one, 6(1), e14543.*. The `SSVEP template` can be decomposed into two components: impulse response and periodic impulse. In ideal case, **the impulse response includes the subject-specific knowledge (e.g., the shape, the latency, and etc) and frequency-non-specific. The periodic impulse is frequency-specific and subject-non-specific**.

In summary, the spatial filter and the impulse response are frequency-non-specific, which can be simply transferred across different frequencies. The idea of transferring the subject-specific knowledge across frequencies is, 

1)The spatial filter and the impulse response learned from the old scheme can be directly applied for the new scheme. (The spatial filter for the old and new visual stimulation schemes are the same)  
2)The new SSVEP template can be reconstructed using the impulse response and the new periodic impulse. The new period impulse can be artificially generated.

Based on this idea, we develop a CCA-based algorithm to use the transferred knowledge, i.e., transferred spatial filter and transferred SSVEP template, for SSVEP recognition. We call this method, the transfer learning CCA (tlCCA).

# Matlab code
The matlab file `demo_ssvep_recognition_with_stimulus_transfer_20220622.m` provides a demo code of testing the tlCCA performance on three different datasets. The first two datasets are **benchmark dataset** and **BETA dataset**, which can be freely downloaded in http://bci.med.tsinghua.edu.cn/. The third dataset comes from the China BCI competition in 2019 (https://www.datafountain.cn/competitions/340, maybe it is not available for download now).  

This demo also tests the recognition performance of the other algorithms, such as the extended CCA (eCCA), the ensemble task-related component analysis (eTRCA), the multi-stimulus eCCA, the multi-stimulus eTRCA, the task-discriminant component analysis (TDCA). For more details about them, please refer to [1-4].

*[3] Chen, X., et al. (2015). High-speed spelling with a noninvasive brain–computer interface. Proceedings of the national academy of sciences, 112(44), E6058-E6067.*  
*[4] Liu, B., et al. (2021). Improving the performance of individually calibrated ssvep-bci by task-discriminant component analysis. IEEE Transactions on Neural Systems and Rehabilitation Engineering, 29, 1998-2007.*  

Note that the CCA is `calibration-free algorithm`. The eCCA, the eTRCA, the ms-eCCA, the ms-eTRCA, the ms-eCCA+ms-eTRCA, and the TDCA are `calibration-based algorithms`. The tlCCA-1 and the tlCCA-2 are `re-calibration-free algorithms`. In most cases, the performance of the `calibration-based algorithm` is usually better than the `calibration-free algorithm` and the `re-calibration-free algorithm`.

>Our IEEE TASE paper only tested the performance of the tlCCA-1 on the BCI competition 2019 dataset. The main difference between the tlCCA-1 and the tlCCA-2 is whether the CCA coefficient is included or not. So this github can provide the more general performance of the tlCCA.


# Experiment study
## Key parameters  
The parameter `transfer_type` is used to select what frequencies are considered as the source group. Now we only have two options:  
1: Source group: 8.0, 8.4, 8.8, ..., 15.6 Hz, Target group: 8.2, 8.6, 9.0, ..., 15.8 Hz  
2: Source group: 8.2, 8.6, 9.0, ..., 15.8 Hz, Target group: 8.0, 8.4, 8.8, ..., 15.6 Hz  

The parameter `dataset_no` is used to select the dataset in the study.  
1: benchmark dataset, 2: BETA dataset, 3: BCI competiton 2019 dataset  

The parameter `enable_bit` is used to select the recognition algorithm in the study.  
enable_bit(1)=1: CCA, eCCA,   
enable_bit(2)=1: ms-eCCA,   
enable_bit(3)=1: eTRCA,   
enable_bit(4)=1: ms-eTRCA,   
enable_bit(2)=1 and enable_bit(4)=1: ms-eCCA+ms-eTRCA,   
enable_bit(5)=1: TDCA,   
enable_bit(6)=1: tlCCA-1, tlCCA-2.

## Testings
### 1) dataset_no=1; is_center_std=0; min_length=0.3; max_length=1.2; enable_bit=[1 1 1 1 1 1];  

When transfer_type=1, we have  
![Result11](https://github.com/edwin465/SSVEP-tlCCA/blob/main/benchmark_1.png)  

When transfer_type=2, we have  
![Result12](https://github.com/edwin465/SSVEP-tlCCA/blob/main/benchmark_2.png)  

The grand average of all the results are listed as below:  

|  |CCA      |	eCCA   |	ms-eCCA |	eTRCA  |	ms-eTRCA |	ms-eCCA+ms-eTRCA |	TDCA   |	tlCCA_1 |	tlCCA_2 |  
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |  
|Avg.|	56.61% |	86.60% |	90.48% |	90.05% |	90.15% |	92.26% |	90.95% |88.15% |	87.00% |  

### 2) dataset_no=2; is_center_std=0; min_length=0.3; max_length=1.2; enable_bit=[1 1 1 1 1 1];  

When transfer_type=1, we have  
![Result21](https://github.com/edwin465/SSVEP-tlCCA/blob/main/BETA_1.png)  

When transfer_type=2, we have  


The grand average of all the results are listed as below:  

|  |CCA      |	eCCA   |	ms-eCCA |	eTRCA  |	ms-eTRCA |	ms-eCCA+ms-eTRCA |	TDCA   |	tlCCA_1 |	tlCCA_2 |  
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |  
|Avg.|	51.35%|	74.54%|	79.71%	|73.93%|	74.75%|	81.63%|	75.74%|	81.97%|	79.93% |



### 3) dataset_no=3; is_center_std=0; min_length=0.3; max_length=1.2; enable_bit=[1 1 1 1 1 1];  

When transfer_type=1, we have  
![Result31](https://github.com/edwin465/SSVEP-tlCCA/blob/main/bci_competition_2019_1.png)  

When transfer_type=2, we have  
![Result32](https://github.com/edwin465/SSVEP-tlCCA/blob/main/bci_competition_2019_2.png)

The grand average of all the results are listed as below:  

|  |CCA      |	eCCA   |	ms-eCCA |	eTRCA  |	ms-eTRCA |	ms-eCCA+ms-eTRCA |	TDCA   |	tlCCA_1 |	tlCCA_2 |  
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |  
|Avg.|	44.65% |	67.40%  |	73.43% |	62.61%   |	63.74%           |	75.33% |	65.35%  |	76.13%  |	72.89%  |  





# Version 
v1.0: (22 Jun 2022)  

# Citation  
If you use this code for a publication, please cite the following paper:

@article{wong2021transferring,  
  title={Transferring subject-specific knowledge across stimulus frequencies in SSVEP-based BCIs},  
  author={Wong, Chi Man and Wang, Ze and Rosa, Agostinho C and Chen, CL Philip and Jung, Tzyy-Ping and Hu, Yong and Wan, Feng},  
  journal={IEEE Transactions on Automation Science and Engineering},  
  volume={18},  
  number={2},  
  pages={552--563},  
  year={2021},  
  publisher={IEEE}  
}
