# ChangeMamba BCD Dataset Protocol

The released ChangeMamba BCD implementation expects:

dataset/
├── train/
│   ├── T1/
│   ├── T2/
│   └── GT/
├── test/
│   ├── T1/
│   ├── T2/
│   └── GT/
├── train_set.txt
└── test_set.txt

Each line in the list files contains a filename including its extension, e.g.:

00000.png

The BCD implementation loads GT and divides it by 255 before converting it to integer class labels. Therefore valid binary GT masks must use 0/255 rather than 0/1.

## SYSU

Final reproduction dataset:

- train: 12,000
- test: 4,000
- image size: 256x256
- T1/T2: RGB PNG
- GT: 0/255
- status: PASS

Original A/B/label directories were mapped to T1/T2/GT.

## WHU-CD

Final reproduction dataset:

- train: 4,536
- test: 2,760
- image size: 256x256
- status: PASS

Original GT values were 0/1.

They were converted as:

0 -> 0
1 -> 255

A total of 7,296 GT files were converted to single-channel uint8 0/255 PNG files.

Original data were not modified.

## LEVIR-CD+

Original dataset:

- train image pairs: 637
- test image pairs: 348
- image size: 1024x1024

Processing:

- tile size: 256
- stride: 256
- overlap: 0
- 16 patches generated from each original image

Final dataset:

- train: 10,192 patches
- test: 5,568 patches
- status: PASS

32 original train GT files contained non-binary values 156 or 254.

GT normalization rule:

gt > 0 -> 255
gt == 0 -> 0

Final GT masks are single-channel uint8 PNG files with values strictly in {0,255}.

.DS_Store, __MACOSX and other non-PNG metadata files were excluded.

Original LEVIR-CD+ files were not modified.
