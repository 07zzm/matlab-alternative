# -*- coding: utf-8 -*-
"""tools/mat_interop.py —— .mat 文件互通验证（Python / SciPy 侧）

被 测试-MAT互通.m 调用，用来做**交叉验证**：
SciPy 是独立于 Octave 和 MATLAB 的第三方 MAT 读写实现，
用它读 Octave 写出的文件、再写出文件给 Octave 读，
比"自己写自己读"可靠得多。

用法：
    python tools/mat_interop.py read  <file.mat>    # 读并打印校验值
    python tools/mat_interop.py write <file.mat>    # 写入固定矩阵
"""
import sys

try:
    import numpy as np
    from scipy.io import loadmat, savemat
except Exception as exc:                                  # pragma: no cover
    print("PY_ERROR import failed: %s" % exc)
    sys.exit(2)

# Octave 侧写入时使用的同一个矩阵
REFERENCE = np.array([[16.,  2.,  3., 13.],
                      [ 5., 11., 10.,  8.],
                      [ 9.,  7.,  6., 12.],
                      [ 4., 14., 15.,  1.]])
REFERENCE_SCALAR = 42.5


def do_read(path):
    data = loadmat(path)
    if "A" not in data or "v" not in data:
        print("PY_FAIL missing variables, got: %s" % sorted(k for k in data if not k.startswith("__")))
        return 1
    a = np.asarray(data["A"], dtype=float)
    v = float(np.asarray(data["v"]).ravel()[0])
    match = a.shape == (4, 4) and np.array_equal(a, REFERENCE) and abs(v - REFERENCE_SCALAR) < 1e-12
    print("PY_READ shape=%dx%d sum=%d v=%.4f header=%s" %
          (a.shape[0], a.shape[1], int(a.sum()), v,
           "MATLAB5" if _looks_like_matlab(path) else "UNKNOWN"))
    print("PY_READ_%s" % ("OK" if match else "MISMATCH"))
    return 0 if match else 1


def do_write(path):
    savemat(path, {"A": REFERENCE, "v": REFERENCE_SCALAR})
    print("PY_WRITE_OK path=%s" % path)
    return 0


def _looks_like_matlab(path):
    with open(path, "rb") as fh:
        return fh.read(19) == b"MATLAB 5.0 MAT-file"


if __name__ == "__main__":
    if len(sys.argv) != 3 or sys.argv[1] not in ("read", "write"):
        print("usage: mat_interop.py read|write <file.mat>")
        sys.exit(2)
    sys.exit(do_write(sys.argv[2]) if sys.argv[1] == "write" else do_read(sys.argv[2]))
