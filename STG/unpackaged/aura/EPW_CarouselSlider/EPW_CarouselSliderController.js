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
                            //handle background color of buttons
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
                            
                            //handle font color of buttons
                            var carouselSliderButtonFontColor= component.get("v.carouselSliderButtonFontColor");
                            var carouselSliderAcvtiveButtonFontColor = component.get("v.carouselSliderAcvtiveButtonFontColor");
                            var carouselSliderButtonFontColorCode,carouselSliderButtonColorActiveFontCode;
                            if($A.util.isEmpty(carouselSliderButtonFontColor) || carouselSliderButtonFontColor == 'none'){
                                carouselSliderButtonFontColorCode = "white";
                            }
                            else{carouselSliderButtonFontColorCode=carouselSliderButtonFontColor;}
                            
                            if($A.util.isEmpty(carouselSliderAcvtiveButtonFontColor) || carouselSliderAcvtiveButtonFontColor == 'none'){
                                carouselSliderButtonColorActiveFontCode = "white";
                            }
                            else{carouselSliderButtonColorActiveFontCode=carouselSliderAcvtiveButtonFontColor;}
                            
                            $(".indicators-for-large-devices button").css("color", carouselSliderButtonFontColorCode);
                            $(".indicators-for-large-devices .active button").css("color", carouselSliderAcvtiveButtonFontColor);
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
        //window.open(window.location.origin + window.location.pathname +"portal-content/" + event.getSource().get("v.alt"), "_self");
    },
    
    showFullArticleDivClick: function(component, event, helper) {
        var ctarget = event.currentTarget;
        var carouselId = ctarget.dataset.value;
        window.open(window.location.origin + window.location.pathname +"fullarticledetail?id=" + carouselId,"_self");
        //window.open(window.location.origin + window.location.pathname +"portal-content/" + carouselId,"_self");
    }
    
    
})