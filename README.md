

Make it work on windows

## How to build

### Build WarpCTC

- ensure you have installed required components

  - vs 2017 / vs 2019
  - cuda
  - python 38 and all required python dependencies

- open `x64 Native Tools Command Prompt for VS 2019` command prompt

- navigate to the root folder of `warp-ctc`, simply run

  ```shell
  build-win.cmd
  ```

- if everything is  OK, you'll get the the `warpctc.dll` in the `build` folder

### Install PyTorch bindings

> Assume you're using conda or miniconda

- activate python env

  ```sh
  conda activate py38
  ```

- navigate to the `warp-ctc\pytorch_binding` folder

- run command

  ```sh
  python setup.py install
  ```

- if everything is OK, copy `warpctc.dll` to your python env's root folder, for example: `Miniconda3\envs\py38`, so python can find and load it

### Test

- navigate to somewhere except the `warpctc\pytorch_binding` folder, otherwise you'll get errors like `_warp_ctc module not found`

- start a python cli and inputs

  ```sh
  import warpctc_pytorch
  ```



> My ENV for your reference:
>
> - windows 10 (19041.572)
> - vs 2019
> - miniconda (py38)
> - cuda 11.0



Note: the modification is based on https://github.com/hzli-ucas/warp-ctc#specific-modifications

---

# PyTorch bindings for Warp-ctc

[![Build Status](https://travis-ci.org/SeanNaren/warp-ctc.svg?branch=pytorch_bindings)](https://travis-ci.org/SeanNaren/warp-ctc)

This is an extension onto the original repo found [here](https://github.com/baidu-research/warp-ctc).

## Installation

Install [PyTorch](https://github.com/pytorch/pytorch#installation) v0.4.

`WARP_CTC_PATH` should be set to the location of a built WarpCTC
(i.e. `libwarpctc.so`).  This defaults to `../build`, so from within a
new warp-ctc clone you could build WarpCTC like this:

```bash
git clone https://github.com/SeanNaren/warp-ctc.git
cd warp-ctc
mkdir build; cd build
cmake ..
make
```

Now install the bindings:
```bash
cd pytorch_binding
python setup.py install
```

If you try the above and get a dlopen error on OSX with anaconda3 (as recommended by pytorch):
```bash
cd ../pytorch_binding
python setup.py install
cd ../build
cp libwarpctc.dylib /Users/$WHOAMI/anaconda3/lib
```
This will resolve the library not loaded error. This can be easily modified to work with other python installs if needed.

Example to use the bindings below.

```python
import torch
from warpctc_pytorch import CTCLoss
ctc_loss = CTCLoss()
# expected shape of seqLength x batchSize x alphabet_size
probs = torch.FloatTensor([[[0.1, 0.6, 0.1, 0.1, 0.1], [0.1, 0.1, 0.6, 0.1, 0.1]]]).transpose(0, 1).contiguous()
labels = torch.IntTensor([1, 2])
label_sizes = torch.IntTensor([2])
probs_sizes = torch.IntTensor([2])
probs.requires_grad_(True)  # tells autograd to compute gradients for probs
cost = ctc_loss(probs, labels, probs_sizes, label_sizes)
cost.backward()
```

## Documentation

```
CTCLoss(size_average=False, length_average=False)
    # size_average (bool): normalize the loss by the batch size (default: False)
    # length_average (bool): normalize the loss by the total number of frames in the batch. If True, supersedes size_average (default: False)

forward(acts, labels, act_lens, label_lens)
    # acts: Tensor of (seqLength x batch x outputDim) containing output activations from network (before softmax)
    # labels: 1 dimensional Tensor containing all the targets of the batch in one large sequence
    # act_lens: Tensor of size (batch) containing size of each output sequence from the network
    # label_lens: Tensor of (batch) containing label length of each example
```