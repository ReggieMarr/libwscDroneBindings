import ctypes
from numpy.ctypeslib import ndpointer

import pathlib
import os

# current_dir = pathlib.Path(__file__).parent
# libname = os.path.abspath(
    # os.path.join(os.path.dirname(__file__), "./dist/lib/libwscDroneBindings.so.0.0"))
# lib = ctypes.cdll.LoadLibrary("./dist/lib/libwscDroneBindings.so.0.0")
lib = ctypes.CDLL("./dist/lib/libwscDroneBindings.so")

# lib = ctypes.cdll.LoadLibrary('/home/hackathon/libraries/libwscDroneBindings/dist/lib/libwscDroneBindings.so')#'./libwscDroneBindings.so')

class PyBebop(object):
    def __init__(self, val):
        lib.CppPyIF.argtypes = [ctypes.c_int]
        lib.CppPyIF.restype = ctypes.c_void_p

        lib.CppPyIF_getBatteryLevel.argtypes = [ctypes.c_void_p]
        lib.CppPyIF_getBatteryLevel.restype = ctypes.c_int

        lib.CppPyIF_takeoffDrone.argtypes = [ctypes.c_void_p]
        lib.CppPyIF_takeoffDrone.restype = ctypes.c_void_p

        lib.CppPyIF_killDrone.argtypes = [ctypes.c_void_p]
        lib.CppPyIF_killDrone.restype = ctypes.c_void_p

        lib.CppPyIF_getBuff.argtypes = [ctypes.c_void_p]
        lib.CppPyIF_getBuff.restype = ndpointer(dtype=ctypes.c_uint8, shape=(480,856,3))

        lib.CppPyIF_moveRelativeMetres.argtypes = [ctypes.c_void_p,ctypes.c_float,ctypes.c_float]
        lib.CppPyIF_moveRelativeMetres.restype = ctypes.c_void_p

        lib.CppPyIF_landDrone.argtypes = [ctypes.c_void_p]
        lib.CppPyIF_landDrone.restype = ctypes.c_void_p

        self.obj = lib.CppPyIF(val)

    def land(self):
        lib.CppPyIF_landDrone(self.obj)

    def moveRelativeMeters(self,x,y):
        lib.CppPyIF_moveRelativeMetres(self.obj,x,y)

    def getBatteryLevel(self):
        return lib.CppPyIF_getBatteryLevel(self.obj)

    def takeoff(self):
        lib.CppPyIF_takeoffDrone(self.obj)

    def die(self):
        lib.CppPyIF_killDrone(self.obj)

    def getBuff(self):
        return lib.CppPyIF_getBuff(self.obj)
