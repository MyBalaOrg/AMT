({
    doInit : function(component, event, helper) {
        /*var contentHeight = Math.max(document.body.offsetHeight, 
                                     document.body.clientHeight, 
                                     document.body.scrollHeight);
        var footerHeight = Math.max(document.getElementById("footer-component-id").offsetHeight,
                                    document.getElementById("footer-component-id").clientHeight,
                                    document.getElementById("footer-component-id").scrollHeight);
        var additionalOffset = 25;
        
        if((contentHeight + footerHeight + additionalOffset) < window.innerHeight) {
            $A.util.addClass(component.find("footer-component"), 'stick-footer-to-bottom');
        } else {
            $A.util.removeClass(component.find("footer-component"), 'stick-footer-to-bottom');
        }*/
        
        var heightOfHeader = component.get("v.heightOfCommunityHeaderCmp");
        var contentHeight = Math.max(document.body.offsetHeight, 
                                     document.body.clientHeight);
        var footerHeight = $A.util.hasClass(component.find("footer-component"), 'stick-footer-to-bottom') ? Math.max(document.getElementById("footer-component-id").offsetHeight,
                                                                                                         document.getElementById("footer-component-id").clientHeight) : 0;
        if((heightOfHeader + contentHeight + footerHeight) <= window.innerHeight) {
            $A.util.addClass(component.find("footer-component"), 'stick-footer-to-bottom');
        } else {
            $A.util.removeClass(component.find("footer-component"), 'stick-footer-to-bottom');
        }
        
        
        
        /* $(window).scroll(function() {/*$("body").css('margin-bottom', $("#main-component").height());
        }); */
        
        /* new code*/
        /*   <script>
        $(document).ready(function () 
                         
        
            // calculate element sizes here is accurate because the entire page has been loaded
            $(window).load(function(){
        
                function fixFooter(){
                    var windowHeight = $(window).height();
                    var bodyHeight = $('body').height();
                    var footerBottom = $('.footer').position().top + $('.footer').outerHeight(true);
        
                    if(footerBottom < windowHeight){
                        // slam the footer to the bottom
                        $('.footer').css("position", "absolute");
                        $('.footer').css("left", 0);
                        $('.footer').css("right", 0);
                        $('.footer').css("bottom", 0); 
                    }
                }
        
                fixFooter();
        
                $(window).resize(function(){
                    fixFooter();
                });
        
            });
        });  
        </script>*/
        /*var docHeight = $(window).height();
        var footerHeight = $('#main-component').height();
        var footerTop = $('#main-component').position().top + footerHeight;
        
        if (footerTop < docHeight) {
            $('#main-component').css('margin-top', 10+ (docHeight - footerTop) + 'px');
        }   */     
        
        
			
        
    },
    
    /**
    *------------------------------------------
    * @Name: navigateToURL
    * @Description
    * navigates to specified URL in footer
    *------------------------------------------
    * @param    component, event, helper		reference to component, event and helper
    * @return   
    *------------------------------------------
    **/
    navigateToURL : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": component.get("v.url")
        });
        urlEvent.fire();
    }
})