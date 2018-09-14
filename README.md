# Motor imagery-based single-channel EEG classification
submitted to Global SIP 2018

__\<Despription\>__***
- Matlab scripts in this repository determined the best combination of channel (22 ch), feature (power spectrum, gray-level co-occurence matrix (GLCM), and single-channel CSP (SCCSP)), and classifer (linear discriminant analysis (LDA), k-nearest neighbor (k-NN), Gaussian mixture model (GMM), random forest (RF), multi-layer perceptron (MLP), and support vector machine (SVM)) that maximizes the classification accuracy of single-channel EEG-based motor imagery BCIs.<br />
SVM with PS and MLP with SCCSP showed 86.6% classification accuracy for one subject in binary classification (mean: 63.5%).<br />  

- For the assessment, we used an open-access dataset, <a href="http://www.bbci.de/competition/iv/#datasets" target="_blank">BCI competition IV dataset 2a</a>.  
Please send <a href="http://www.bbci.de/competition/iv/#download" target="_blank">e-mail</a> to access the data before using our codes.

- This repository has a main m.file:<br />
