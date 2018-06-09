<!--
/**
*___________________________________________________
*@Name: ST_ObservationSubmissionApp
*@Author: Max Paquin mpaquin@goaldc.com
*@Created Date: 4/19/2017
*@Used By: SafeTrends App
*___________________________________________________
*@Description:
*
*___________________________________________________
*@Changes
* MM-DD-YYY. Explanation of the change.
**/
-->
<aura:application access="GLOBAL" extends="ltng:outApp">

  <!-- add the following to the aura:application tag once ready to add to VF page
	extends="ltng:outApp"
	extends="force:slds"
   -->
   <!-- replace the c:ST_ObservationSubmissionCmp with the dependecy below once ready to add to VF Page-->
  <aura:dependency resource="c:ST_ObservationSubmissionCmp"/> 
  
  <!--
  <c:ST_ObservationSubmissionCmp />
  -->
  <!-- required to handle force: events in visualforce page-->
  <aura:dependency resource="markup://force:*" type="EVENT"/>
  
</aura:application>