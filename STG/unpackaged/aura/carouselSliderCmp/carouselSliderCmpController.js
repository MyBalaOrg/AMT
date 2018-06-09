({
    /**
    *------------------------------------------
    * @Name: doInit
    * @Description
    * This function initializes the component, sets carousal attribute, handles indicators 
    * visibility on screen resize, sets the backgroud image for slider and starts the slider
    *------------------------------------------
    * @param    component, event, helper		reference to component, event and helper
    * @return   
    *------------------------------------------
    **/
    doInit: function(component, event, helper) {
        helper.handleIndicatorsOnScreenResize(component);
        var action = component.get("c.getPortalContent");
        action.setParams({
            "application" : component.get("v.application")
        });
        action.setCallback(this, function(response){
            if(component.isValid() && response.getState() === "SUCCESS"){
                var carousel = response.getReturnValue();
                if(carousel != null) {
                    helper.handleTruncation(carousel);
                    component.set("v.carousel", carousel);
                    helper.setBackgroundImage(component);
                    
                    var speed = carousel.Slider_Transition_Time__c;
                    if(!$A.util.isEmpty(speed)) {
                        $('.carousel').carousel({
                            interval: speed,
                            pause : "hover"
                        });
                        $("#myCarousel").on('slid.bs.carousel', function () {
                            var carouselSliderButtonColor= component.get("v.carouselSliderButtonColor");
                            var carouselSliderButtonColorActive = component.get("v.carouselSliderButtonColorActive");
                            var carouselSliderButtonColorCode,carouselSliderButtonColorActiveCode;
                            if($A.util.isEmpty(carouselSliderButtonColor) || carouselSliderButtonColor == 'none'){
                                carouselSliderButtonColorCode = "#167fa6";
                            }
                            else{carouselSliderButtonColorCode=carouselSliderButtonColor;}
                            
                            if($A.util.isEmpty(carouselSliderButtonColorActive) || carouselSliderButtonColorActive == 'none'){
                                carouselSliderButtonColorActiveCode = "#1ca1d3";
                            }
                            else{carouselSliderButtonColorActiveCode=carouselSliderButtonColorActive;}
                            
                            $(".indicators-for-large-devices button").css("background-color", carouselSliderButtonColorCode);
                            $(".indicators-for-large-devices .active button").css("background-color", carouselSliderButtonColorActiveCode);
                        });
                    }
                }
            }         
        });
        $A.enqueueAction(action);
    },
    
    /**
    *------------------------------------------
    * @Name: showFullArticle
    * @Description
    * This function redirects to Full Artical Ddetail page for selected slide
    *------------------------------------------
    * @param    component, event, helper		reference to component, event and helper
    * @return   
    *------------------------------------------
    **/
    showFullArticle: function(component, event, helper) {
       window.open(window.location.origin + window.location.pathname +"fullarticledetail?id=" + event.getSource().get("v.alt"), "_self");
    }
})