Yet Another Persistent Scratch
====================================

### Introduction
This package makes your `*scratch*` buffer persistent and not killable (bury instead).

### Install
If you don't have ELPA package in your Emacs, clone this repository and load file.
```shell
git clone https://github.com/rayw000/yaps.git
```
```emacs-lisp
(load-file "/path/to/yaps/yaps.el")
(require 'yaps)
```
Or install with ELPA
```
package-install <RET> yaps <RET>
```
Once you require `yaps` package, it will be automatically enabled in your `*scratch*` buffer.

### Usage
You don't need much configurations to use this package. After install and properly load it, you can enjoy it in your `*scratch*` buffer.

### Functions
`yaps-save-scratch-data`: Save scratch contents into `yaps-data-directory`. `C-x C-s` is remapped to this function.

`yaps-clear-scratch-data`: Clear scratch contents.

`yaps-bury-scratch-buffer`: Bury (instead of kill) scratch buffer.

`yaps-restore-data-from-file`: Restore data from yaps data file.

### Customizations

- Variables
`yaps-scratch-buffer-name`: Buffer name which you want to use `yaps` with, default to `*scratch*`.
`yaps-data-directory`: Directory to store yaps data file `yaps.data`.

- Key bindings
You can bind your favorite keys in `yaps-mode-map`. For example,
```emacs-lisp
(define-key yaps-mode-map (kbd "C-c C-r") 'yaps-restore-data-from-file)
```

### Similar packages:
[persistent-scratch](https://github.com/Fanael/persistent-scratch)
