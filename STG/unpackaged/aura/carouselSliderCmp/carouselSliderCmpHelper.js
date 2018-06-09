({
    /**
    *------------------------------------------
    * @Name: handleIndicatorsOnScreenResize
    * @Description
    * Hides button's indicator which is used for descktop version when screen resizes to mobile view 
    *------------------------------------------
    * @param    component		reference to component
    * @return   
    *------------------------------------------
    **/
    handleIndicatorsOnScreenResize : function (component) {
        if( $( window ).width() < 1100 ){
            if($( ".indicators-for-large-devices" )) {
                $( ".indicators-for-large-devices" ).remove();
            }
        }
    },
    
    /**
    *------------------------------------------
    * @Name: handleIndicatorsOnScreenResize
    * @Description
    * This function fetches image from carousal attachment and sets it as carousal background image
    *------------------------------------------
    * @param    component		reference to component
    * @return   
    *------------------------------------------
    **/
    setBackgroundImage : function (component) {
        var action = component.get("c.getContents");
        action.setParams({parentId : component.get("v.carousel").Id});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS' && $A.get("$Label.c.Prefix_URL") != null) {
                if(response.getReturnValue() != null){
                 	component.set("v.contents", response.getReturnValue()); 
                	$('#myCarousel').css('background-image', 'url("' + window.location.pathname.substring(0, window.location.pathname.indexOf("/s/")) + $A.get("$Label.c.Prefix_URL") + component.get("v.contents")+'")');   
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    /**
    *------------------------------------------
    * @Name: handleTruncation
    * @Description
    * Text truncation logic for Title, Subtitle and Description field of carousal object 
    * without breaking the last word.
    *------------------------------------------
    * @param    carousel		reference to carousel object
    * @return   
    *------------------------------------------
    **/
    handleTruncation : function(carousel) {
        var maxLengthForTitle = 60;			//two line text
        var maxLengthForSubTitle = 45;		//one line text
        var maxLengthForDescription = 210;	//4 line text
        if(carousel.Slides__r != null && carousel.Slides__r.length > 0) {
            for(var i = 0; i < carousel.Slides__r.length; i++) {
                var eachSlide = carousel.Slides__r[i];
                //handle truncation for Title
                if(eachSlide.Title__c != null && eachSlide.Title__c.length > maxLengthForTitle) {
                    var truncatedText = eachSlide.Title__c.trim().substring(0, maxLengthForTitle);
                    truncatedText = this.truncateWithoutWordBread(truncatedText);
                    eachSlide.Title__c = truncatedText;
                }
                
                //handle truncation for SubTitle
                if(eachSlide.Subtitle__c != null && eachSlide.Subtitle__c.length > maxLengthForSubTitle) {
                    var truncatedText = eachSlide.Subtitle__c.trim().substring(0, maxLengthForSubTitle);
                    truncatedText = this.truncateWithoutWordBread(truncatedText);
                    eachSlide.Subtitle__c = truncatedText;
                }
                
                //handle truncation for Description
                if(eachSlide.Description__c != null && eachSlide.Description__c.length > maxLengthForDescription) {
                    var truncatedText = eachSlide.Description__c.trim().substring(0, maxLengthForDescription);
                    truncatedText = this.truncateWithoutWordBread(truncatedText);
                    eachSlide.Description__c = truncatedText;
                }                
            }
        }
    },
    
    /**
    *------------------------------------------
    * @Name: truncateWithoutWordBread
    * @Description
    * Truncates text without breaking last work
    *------------------------------------------
    * @param    text		text to be truncated
    * @return   
    *------------------------------------------
    **/
    truncateWithoutWordBread : function(text) {
        return text.substring(0, Math.min(text.length, text.lastIndexOf(" "))) + '...';
    }
})