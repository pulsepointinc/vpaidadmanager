window.ppa.jsvpaid.DomHelper = function() {
    this.classConstructor = arguments.callee;
    this.classConstructor.VALID_URL_REGEX = new RegExp(/(http|ftp|https):\/\/[\w\-_]+(\.[\w\-_]+)+([\w\-\.,@?^=%&:\/~\+#]*[\w\-\@?^=%&\/~\+#])?/);

    this.classConstructor.getXMLNodeValue = function(node, name) {
        if (node) {
            if (name) {
                var nodeValue = node.getElementsByTagName(name);
                if (nodeValue.length > 0 && nodeValue[0].firstChild) {
                    if (nodeValue[0].firstChild.wholeText) {
                        return nodeValue[0].firstChild.wholeText.trim();
                    }
                    return nodeValue[0].firstChild.nodeValue;
                }
            } else {
                if (node.firstChild) {
                    if (node.firstChild.wholeText) {
                        return node.firstChild.wholeText.trim();
                    }
                    return node.firstChild.nodeValue;
                }
            }
        }

        return "";
    };
};

new window.ppa.jsvpaid.DomHelper();
