Exception decompressing RLE encoded data with non-conformant padding
Getting Following error 
"Could not convert:  The amount of decoded RLE segment data doesn't match the expected amount (786433 vs. 786432 bytes)"
For following code
plt.imsave(os.path.join(output_folder,file)+'.png', convert_color_space(ds.pixel_array, ds[0x28,0x04].value, 'RGB'))
Also attaching DICOM file 
[US.1.2.156.112536.1.2127.130145051254127131.13912524190.144.txt](https://github.com/pydicom/pydicom/files/6799721/US.1.2.156.112536.1.2127.130145051254127131.13912524190.144.txt)

Please remove .txt extension to use DICOM file



