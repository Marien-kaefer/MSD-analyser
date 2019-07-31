#H1 Matlab script implementing the [@msdanalyzer class](https://github.com/tinevez/msdanalyzer) written by @tinevez

Matlab script to generate Mean Squared Displacement curves of Tracks generated via the Fiji TrackMate plugin

1. Preparations
  * Export a simplified XML file containing only the tracks as spot positions
  * Install the @msdanalyzer class as per the [installation instructions](https://tinevez.github.io/msdanalyzer/)
2. Running the script
  * Open the `TrackAnalysis_msdAnalyser.m` script in matlab and run it
  * The user is presented with an image displaying some instructions and some model MSD curves depicting typical Brownian motion, Transported movement and Confined movement. 
  * The user is requested to select a file containing the track data that is to be analysed.
  * The data is now being read and depending on the number and length of tracks, this can take a while. 
  * Once the data is loaded, the mean square displacement curves for each track and the average mean square displacement curve are being calculated and subsequently displayed. The user is now prompted to provide the temperature - in °C - at which the experiment has been run.
  * Once the temperature has been provided, another prompt pops up requesting which of the modes of transport the MSD curve generated from the loaded data resembles most. Three exemplary curves are displayed in the instruction window and the user has to chose one to proceed with the analysis. If cancel is chosen, the script will finish without analysis of the curve.
    2.1 **Brownian motion option:** The Brownian motion option does not require any further input and will print the calculated Diffusion constant and goodness of fit in the Command window. In the MSD graph, the fitted line and the confidence intervals will be displayed. The final diffusion constant is calculated on only the first 25% of each curve. The value can be copied and pasted for future use.
	2.2 **Transported movement option: ** The transported movement option does not require any further input and will calculate and print the diffusion constant and velocity of motion in the Command window. The values can be copied and pasted from there for future use. 
	2.3 **Confined movement option: ** The Confined movement option requires further input from the user which is requested via a pop up window. The user is requested to estimate the approximate percentage of the curve that is linear before saturation sets in. The estimated diffusion coefficient through linear fit of the mean MSD curve is given with a 95 % confidence interval. The calculated goodness of fit is also given. The fit is performed on the initial data points. 
  
  
#H2 License
This code is licensed under the GNU General Public License Version 3.

For more information contact m.held@liverpool.ac.uk.