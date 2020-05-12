# Motor imagery-based single-channel EEG classification

This code is described in the paper
`A Comparative Study of Features and Classifiers in Single-channel EEG-based Motor Imagery BCI` 
accepted by *Global SIP 2018*.<br />

### \<Overview\>
- Matlab scripts in this repository determined __the best combination of channel, feature, and classifer that maximizes the classification accuracy of single-channel EEG-based motor imagery BCIs.__<br />
  - channel: 22 ch
  - feature: 
    - power spectrum (PS)
    - gray-level co-occurence matrix (GLCM)
    - single-channel common spatial pattern (SCCSP)
  - classifier:
    - linear discriminant analysis (LDA)
    - k-nearest neighbor (k-NN)
    - Gaussian mixture model (GMM)
    - random forest (RF)
    - multi-layer perceptron (MLP)
    - support vector machine (SVM)

  - SVM with PS and MLP with SCCSP showed __86.6% classification accuracy__ for one subject in binary classification (mean: 63.5%).<br />  

- For the assessment, we used an open-access dataset, <a href="http://www.bbci.de/competition/iv/#datasets" target="_blank">BCI competition IV dataset 2a</a>.  
Please send <a href="http://www.bbci.de/competition/iv/#download" target="_blank">e-mail</a> to access the data before using our codes.

### \<Code\>
- This repository has a main m.file which is consisted of preprocessing and postprocessing steps.<br />
- You can calculate classification accuracies with 10-fold cross validation after saving feature vectors through preprocessing step.<br />
- In addition, you can change each parameter in this framework by changing the value in set_config.m file.<br />

### \<Environments\>
MALBAB R2017a
 1. Signal Processing Toolbox
 2. Statics and Machine Learning Toolbox
 3. Image Processing Toolbox
 4. Neural Network Toolbox
 5. <a href="http://biosig.sourceforge.net/download.html" target="_blank">BioSig for Octave and Matlab v3.2.0</a>
 6. <a href="https://www.csie.ntu.edu.tw/~cjlin/libsvm/#matlab" target="_blank">LIBSVM for matlab</a>
