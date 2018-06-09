({
  renderIcon: function(component) { // renderIcon add tags create svg tag
    var prefix = "slds-";
    var svgns = "http://www.w3.org/2000/svg";
    var xlinkns = "http://www.w3.org/1999/xlink";
    var size = component.get("v.size");
    var name = component.get("v.name");
    var classname = component.get("v.class");
    var category = component.get("v.category");

    var containerClassName = [
        prefix+"icon__container",
        prefix+"icon-"+category+"-"+name,
        classname
        ].join(' ');
    var iconClassName = prefix+"icon "+prefix+"icon--" + size;
    component.set("v.containerClass", containerClassName);

    var svgroot = document.createElementNS(svgns, "svg");
    svgroot.setAttribute("aria-hidden", "true");
    svgroot.setAttribute("class", iconClassName);
    svgroot.setAttribute("name", name);

    // Add an "href" attribute (using the "xlink" namespace)
    var shape = document.createElementNS(svgns, "use");
    shape.setAttributeNS(xlinkns, "href", component.get("v.svgPath"));
    svgroot.appendChild(shape);

    var container = component.find("container").getElement();
    container.insertBefore(svgroot, container.firstChild);
  },
    detectIE: function(cmp) { // If older version of IE produce class that only shows png equivalent
                var span = cmp.find("container");
                var browser="Not IE",version="";
                var ua = navigator.userAgent;
        		var newClass = '';
        
                var iePos = ua.indexOf("MSIE");
               	var rvPos = ua.indexOf(" rv:");        
				//console.log(ua);

                if (iePos!=-1) {
                    browser = "IE";
                    version = parseInt(ua.substring(iePos+5));
                    newClass = browser+'_'+version;              
					$A.util.addClass(span, newClass);
                } else if (rvPos!=-1) {
                        browser = "IE";      
                        version = parseInt(ua.substring(rvPos+4));
                        newClass = browser+'_'+version;
                    	$A.util.addClass(span, newClass);
                }
    }                          
})