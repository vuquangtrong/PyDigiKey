from PySide2 import QtCore
from PySide2.QtCore import QObject, Property, Signal, Slot

from .performance import Performance

class Location(QObject):

    ### SIGNALS
    updated = Signal()


    ### METHODS
    def __init__(self, parent=None, x=-1000.0, y=-1000.0, z=0):
        super().__init__(parent)
        self.__coordinate = [x, y, z]
        self.__distance = [0.0 for _ in range(8)]  # D1 ~ D8
        self.__activated_anchors = [False for _ in range(8)] # A1 ~ A8
        self.__performance = [Performance() for _ in range(8)] # A1 ~ A8
        self.__zone = -1


    def get_coordinate(self):
        #print("get_coordinate", self.__coordinate)
        return self.__coordinate


    def set_coordinate(self, value):
        if value != self.__coordinate:
            self.__coordinate = value
            #print("set_coordinate", self.__coordinate)
            self.updated.emit()

    def get_distance(self):
        #print("get_distance", self.__distance)
        return self.__distance


    def set_distance(self, value):
        if value != self.__distance:
            self.__distance = value
            #print("set_distance", self.__distance)
            self.updated.emit()

    def get_activated_anchors(self):
        #print("get_activated_anchors", self.__activated_anchors)
        return self.__activated_anchors


    def set_activated_anchors(self, value):
        if value != self.__activated_anchors:
            self.__activated_anchors = value
            #print("set_activated_anchors", self.__activated_anchors)
            self.updated.emit()

    def get_performance(self):
        #print("get_performance", self.__performance)
        return self.__performance


    def set_performance(self, value):
        if value != self.__performance:
            self.__performance = value
            #print("set_performance", self.__performance)
            self.updated.emit()
    
    def get_zone(self):
        #print("get_zone", self.__zone)
        return self.__zone


    def set_zone(self, value):
        if value != self.__zone:
            self.__zone = value
            #print("set_zone", self.__zone)
            self.updated.emit()

    ## PROPERTIES
    coordinate = Property('QVariantList', fget=get_coordinate, fset=set_coordinate, notify=updated)
    distance = Property('QVariantList', fget=get_distance, fset=set_distance, notify=updated)
    activatedAnchors = Property('QVariantList', fget=get_activated_anchors, fset=set_activated_anchors, notify=updated)
    performance = Property('QVariantList', fget=get_performance, fset=set_performance, notify=updated)
    zone = Property(int, fget=get_zone, fset=set_zone, notify=updated)
