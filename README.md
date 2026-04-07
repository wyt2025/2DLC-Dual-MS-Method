**A column-switching two-dimensional liquid chromatography - high resolution/triple quadrupole dual mass spectrometry system for simultaneous analysis of untargeted metabolomics and targeted exposomics** 





**ABSTRACT**

Exposome-wide association studies (ExWAS) require the detection of metabolites and exposures with diverse chemical properties across wide concentration ranges, a task that typically demands multiple analytical methods. To address this challenge, we developed an integrated column-switching two-dimensional liquid chromatography-dual mass spectrometry (2DLC-dual-MS) system. This system employs a 2DLC setup to sequentially separate polar and nonpolar compounds with log P values ranging from -8 to 15. The separated fractions are directed via a three-way valve to a high-resolution MS (HRMS) and a triple quadrupole MS (TQMS), enabling simultaneous untargeted metabolome analysis and targeted quantification of 601 exposures. The method is particularly suited for the concurrent analysis of metabolome and exposome in human blood, where their concentrations typically differ by 2-3 orders of magnitude. In a demonstration application on lung cancer ExWAS, the system exhibited excellent stability over more than 300 consecutive injections for both metabolome and exposome analysis, confirming its robustness for ExWAS applications.

The R codes for data analysis and generating figures are available at GitHub (https://github.com/wyt2025/2DLC-Dual-MS-Method.git). 



**Software version and installation guide**

Data analysis in this study was performed using R software (version 4.4.1, R Foundation for Statistical Computing, Vienna, Austria). The tested version of the software was R 4.4.1. No non-standard hardware is required for running this software, and it can be installed and used on a standard desktop or laptop computer. The recommended basic hardware configuration includes a 64-bit operating system, at least 4 GB of RAM, and sufficient disk space to support software installation and subsequent data analysis.





**Installation instructions**

R version 4.1.0 can be downloaded from the official R website or a CRAN mirror corresponding to the user’s operating system, and installed using the default installation settings. The installation process is straightforward and does not require any specialized hardware or complex environment configuration. On a typical desktop computer, installation of the base R software usually takes approximately 5–10 minutes. If additional commonly used R packages are also installed, the total setup time is typically 10–30 minutes, depending on network speed, computer performance, and the number of packages installed.





**Which R codes are used in this paper?**

1\. R code for Multiple linear regression

Code: 2DLC-Dual MS Method—code\_WYT/code-2026/Code/Multiple linear regression.R

Example file: 2DLC-Dual MS Method—code\_WYT/code-2026/Example/Multiple linear regression-input.xlsx

&#x20;                      2DLC-Dual MS Method—code\_WYT/code-2026/Example/Multiple linear regression-output.xlsx



2\. R code for Binary logistic regression

Code: 2DLC-Dual MS Method—code\_WYT/code-2026/Code/Binary logistic regression.R

Example file: 2DLC-Dual MS Method—code\_WYT/code-2026/Example/Binary logistic regression-input.xlsx

&#x20;                      2DLC-Dual MS Method—code\_WYT/code-2026/Example/Binary logistic regression-output.xlsx



3. R code for Mediation effect analysis

Code: 2DLC-Dual MS Method—code\_WYT/code-2026/Code/Med-Effect Analysis.R

Example file: 2DLC-Dual MS Method—code\_WYT/code-2026/Example/Med-Effect Analysis-input.xlsx

&#x20;                      2DLC-Dual MS Method—code\_WYT/code-2026/Example/Med-Effect Analysis-output.xlsx



4. R code for Ring Network Diagram

Code: 2DLC-Dual MS Method—code\_WYT/code-2026/Code/Ring Network Diagram.R

Example file: 2DLC-Dual MS Method—code\_WYT/code-2026/Example/edges.csv

&#x20;                      2DLC-Dual MS Method—code\_WYT/code-2026/Example/nodes.csv

Figure file:2DLC-Dual MS Method—code\_WYT/code-2026/Figure/Ring Network Diagram.pdf



5\. R code for Donut Bar Chart

Code: 2DLC-Dual MS Method—code\_WYT/code-2026/Code/Donut Bar Chart.R

Example file: 2DLC-Dual MS Method—code\_WYT/code-2026/Example/Donut Bar Chart-data.tsv

Figure file: 2DLC-Dual MS Method—code\_WYT/code-2026/Figure/Donut Bar Chart.pdf



6\. R code for Sunrise plot

Code: 2DLC-Dual MS Method—code\_WYT/code-2026/Code/Sunrise plot.R

&#x20;          2DLC-Dual MS Method—code\_WYT/code-2026/Code/pie\_donut.R

Figure file: 2DLC-Dual MS Method—code\_WYT/code-2026/Figure/Sunrise plot.png



