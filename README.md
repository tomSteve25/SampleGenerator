# Sample Generator

A Windows Flutter project aimed at photographers needing to create samples to send to clients. This tool allows for mass creation of downsized, reduced quality samples with watermarks that can be sent to clients.

## Usage

1. Download the installer from the **Releases** tab. NOTE: Has only been tested on Windows 11, but should work in theory for Windows 10.
2. Set the image directory.
   * This is the directory of images that will be processed.
3. Select the watermark image
    * For best results use a transparent PNG
4. OPTIONAL - set the output directory
    * This will default to a subdirectory of the input folder called `output`
5. Select the watermark position
   * Center, any corner
6. Change the image and watermark scales
   * This is the factor that the sides of the image are reduced by. For example if the original image was 5392x3592, a scale of 10 would result in a new size of 539x539.
   * Watermark should be smaller than main image for best results
7. Click **Generate Samples**
   * A loading bar will show progress.

## Planned improvements
* An easy way to see your settings other than running on an entire directory
* A way to change the quality
  * Currently, the original image is downsized, then uses JPEG encoding with a quality factor of 50% to reduce the image quality before applying the watermark.
* A way to offset the watermark in either direction
* A way to automatically scale the watermark based on a size ratio between it and the original image
* Make the watermark optional so the tool can be used for downsizing and quality reduction only


## Bugs and requests
Please use the Issues tab to report any bugs or make any requests