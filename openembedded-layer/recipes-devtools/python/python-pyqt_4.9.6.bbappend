# Fix terribly broken Qt.py (literal \n's)
do_install_append () {
    for module in ${SIP_MODULES}; do
        echo "from PyQt4.$module import *"
    done >${D}${libdir}/${PYTHON_DIR}/site-packages/PyQt4/Qt.py
}

# Another try/except import block. Use 'xml.etree.ElementTree', not these
AUTO_PYTHON_DEPENDS_EXCLUDE += "\
    python-pyqt:ElementPath \
    python-pyqt:elementtree.ElementTree \
    python-pyqt:PyQt4.elementtree.ElementTree \
"
