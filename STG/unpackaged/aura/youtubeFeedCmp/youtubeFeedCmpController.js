({ 
    doInit : function(component, event, helper) {        
        helper.getVideoIdFromObject(component, event, helper);     
        
        var id = (new Date()).getTime( );
        component.set( "v.id", id ); 
        $A[ 'youtube-videoplayer' + id ] = {};
        if( component.get( "v.fullscreen") ){
            component.set( "v.width", "100%" );
            component.set( "v.height", "100%" );
            component.set( "v.fullscreen_class", "full_screen" );
        };
        
    },
    afterScriptsLoaded : function(component, event, helper) { 
        var youtube_videoplayer = $A[ 'youtube-videoplayer' + component.get( "v.id") ];
        youtube_videoplayer = new YoutubeVideo();
        youtube_videoplayer.init( {
            id: component.get( 'v.id'),
            fullscreen: component.get( 'v.fullscreen' )
        });
        
        utility.onPageLoad( function(){
            utility.onWindowResize( youtube_videoplayer.adjustImgSizeOnWinResize );
        });
        
        utility.init( );
    }
})