package hud
{
   import common.Animate;
   import common.BaseControl;
   import common.CommonUtils;
   import common.ImageLoader;
   import common.Localization;
   import common.menu.MenuConstants;
   import common.menu.MenuUtils;
   import fl.motion.Color;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.filters.GlowFilter;
   
   public class Weapon extends BaseControl
   {
      
      private static const LEGALSTATE_CLEAR:int = 0;
      
      private static const LEGALSTATE_SUSPICIOUS:int = 1;
      
      private static const LEGALSTATE_ILLEGAL:int = 2;
      
      private static const PX_BLUR:Number = 4;
      
      private var m_view:WeaponView;
      
      private var m_primaryLoader:ImageLoader;
      
      private var m_secondaryLoader:ImageLoader;
      
      private var m_leftHandLoader:ImageLoader;
      
      private var m_currentPrimaryImage:String;
      
      private var m_currentSecondaryImage:String;
      
      private var m_currentLeftHandImage:String;
      
      private var m_currentAmmoInGun:Number;
      
      private var m_currentAmmoInStore:Number;
      
      private var m_currentAmmoInClip:Number;
      
      private var m_currentAmmoType:Number;
      
      private var m_lastWeaponData:Object = new Object();
      
      private var m_lastBackData:Object = new Object();
      
      private var m_lastLeftHandData:Object = new Object();
      
      private var m_primaryLegalState:int = 0;
      
      private var m_secondaryLegalState:int = 0;
      
      private var m_leftHandLegalState:int = 0;
      
      private var m_previousPrimaryLegalState:int = 0;
      
      private var m_previousIsPrimaryHolsteredOnBack:Boolean = false;
      
      private var m_reloadUrgent:Boolean = false;
      
      private var m_weaponBackground:Sprite;
      
      private var m_primaryIsShown:Boolean;
      
      private var m_secondaryIsShown:Boolean;
      
      private var m_leftHandIsShown:Boolean;
      
      private var m_primaryWeaponHolstered:Boolean;
      
      private var m_reloadClipShownWhileHolster:Boolean;
      
      private var m_finalWeaponWasDropped:Boolean;
      
      private var m_reloadAnimIsRunning:Boolean;
      
      private var m_sniperModeIsEntered:Boolean;
      
      private var m_isReloading:Boolean = false;
      
      private var m_fScaleAccum:Number = 1;
      
      public function Weapon()
      {
         super();
         this.m_weaponBackground = new Sprite();
         this.m_weaponBackground.graphics.clear();
         this.m_weaponBackground.graphics.beginFill(MenuConstants.COLOR_MENU_TABS_BACKGROUND,0);
         this.m_weaponBackground.graphics.drawRect(0,0,0,0);
         this.m_weaponBackground.visible = false;
         addChild(this.m_weaponBackground);
         this.m_view = new WeaponView();
         this.m_view.iconPri_mc.alpha = 0;
         this.m_view.iconSec_mc.alpha = 0;
         this.m_view.iconLeftHand_mc.alpha = 0;
         addChild(this.m_view);
         this.m_primaryLoader = new ImageLoader();
         this.m_primaryLoader.visible = false;
         this.m_view.imageHolderPri_mc.addChild(this.m_primaryLoader);
         if(ControlsMain.isVrModeActive())
         {
            this.m_view.imageHolderPri_mc.x = -245;
            this.m_view.iconPri_mc.x = this.m_view.ammoDisplayContainer.x - this.m_view.iconPri_mc.width / 2 - 10;
         }
         this.m_secondaryLoader = new ImageLoader();
         this.m_secondaryLoader.visible = false;
         this.m_view.imageHolderSec_mc.addChild(this.m_secondaryLoader);
         this.m_leftHandLoader = new ImageLoader();
         this.m_leftHandLoader.visible = false;
         this.m_view.imageHolderLeftHand_mc.addChild(this.m_leftHandLoader);
         MenuUtils.trySetCacheAsBitmap(this.m_view.imageHolderPri_mc,true);
         MenuUtils.trySetCacheAsBitmap(this.m_view.imageHolderSec_mc,true);
         MenuUtils.trySetCacheAsBitmap(this.m_view.imageHolderLeftHand_mc,true);
         this.setHolsterEffect(true,this.m_view.imageHolderSec_mc);
         this.m_currentPrimaryImage = "";
         this.m_currentSecondaryImage = "";
         this.m_currentLeftHandImage = "";
         this.m_view.reloadHolder.reload_mc.visible = false;
         this.m_view.ammoDisplayContainer.ammoDisplay.visible = false;
      }
      
      public function onSetData(param1:Object) : void
      {
         var _loc8_:Boolean = false;
         var _loc9_:Boolean = false;
         this.m_view.reloadHolder.visible = param1.nDisplayMode == 0 ? false : true;
         MenuUtils.setupText(this.m_view.reloadHolder.reload_mc.reload_txt,Localization.get("EUI_TEXT_BUTTON_RELOAD"),18,MenuConstants.FONT_TYPE_MEDIUM,MenuConstants.FontColorGreyUltraLight);
         CommonUtils.changeFontToGlobalIfNeeded(this.m_view.reloadHolder.reload_mc.reload_txt);
         if(param1.weaponStatus.bIsContainer)
         {
            return;
         }
         var _loc2_:Object = param1.weaponStatus;
         var _loc3_:Object = param1.itemOnBackStatus;
         var _loc4_:Object = param1.itemLeftHandStatus;
         var _loc5_:Boolean = true;
         var _loc6_:Boolean = true;
         var _loc7_:Boolean = true;
         _loc5_ = _loc2_.icon != this.m_lastWeaponData.icon || _loc2_.bHasItemToShow != this.m_lastWeaponData.bHasItemToShow;
         _loc6_ = _loc3_.icon != this.m_lastBackData.icon || _loc3_.bHasItemToShow != this.m_lastBackData.bHasItemToShow || this.m_lastWeaponData.icon == this.m_lastBackData.icon;
         _loc7_ = _loc4_.icon != this.m_lastLeftHandData.icon || _loc4_.bHasItemToShow != this.m_lastLeftHandData.bHasItemToShow;
         if(_loc2_.bHasItemToShow)
         {
            this.m_primaryLoader.visible = true;
            this.m_primaryIsShown = true;
            if(_loc5_ || _loc2_.bHolstered != this.m_lastWeaponData.bHolstered)
            {
               this.setWeaponIcon(_loc2_.icon);
            }
            _loc8_ = false;
            if(_loc2_.bHolstered != this.m_lastWeaponData.bHolstered)
            {
               if(_loc2_.bHolstered)
               {
                  this.holsterWeapon(!param1.bShowHolstered);
                  if(!this.m_lastWeaponData.bIsFirearm)
                  {
                     _loc8_ = true;
                  }
               }
               else
               {
                  this.unholsterWeapon();
               }
            }
            if(_loc8_)
            {
               this.m_view.ammoDisplayContainer.visible = false;
            }
            else
            {
               Animate.legacyTo(this.m_view.ammoDisplayContainer,0.5,{"alpha":(_loc2_.bHolstered ? 0 : 1)},Animate.ExpoOut);
            }
            if(_loc2_.bIsFirearm)
            {
               this.setWeaponAmmoInfo(_loc2_.nAmmoRemaining,_loc2_.nAmmoTotal,_loc2_.nAmmoInClip,_loc2_.nWeaponType,param1.nDisplayMode,_loc2_.bCanReload,_loc2_.bIsReloading,_loc2_.fReloadDuration);
            }
            else
            {
               this.setWeaponAmmoInfo(-1,_loc2_.nAmmoRemaining,-1,_loc2_.nWeaponType,param1.nDisplayMode,_loc2_.bCanReload,_loc2_.bIsReloading);
            }
            if(_loc2_.bIllegal != this.m_lastWeaponData.bIllegal || _loc2_.bSuspicious != this.m_lastWeaponData.bSuspicious || _loc2_.bHolstered != this.m_lastWeaponData.bHolstered || _loc5_)
            {
               _loc9_ = false;
               if(_loc2_.bIllegal)
               {
                  if(!_loc2_.bHolstered)
                  {
                     this.m_primaryLegalState = LEGALSTATE_ILLEGAL;
                  }
                  else if(_loc2_.icon == _loc3_.icon && Boolean(param1.bShowHolstered))
                  {
                     this.m_primaryLegalState = LEGALSTATE_ILLEGAL;
                     _loc9_ = true;
                  }
                  else
                  {
                     this.m_primaryLegalState = LEGALSTATE_CLEAR;
                  }
               }
               else if(_loc2_.bSuspicious)
               {
                  if(!_loc2_.bHolstered)
                  {
                     this.m_primaryLegalState = LEGALSTATE_SUSPICIOUS;
                  }
                  else if(_loc2_.icon == _loc3_.icon)
                  {
                     this.m_primaryLegalState = LEGALSTATE_SUSPICIOUS;
                     _loc9_ = true;
                  }
                  else
                  {
                     this.m_primaryLegalState = LEGALSTATE_CLEAR;
                  }
               }
               else
               {
                  this.m_primaryLegalState = LEGALSTATE_CLEAR;
               }
               this.updatePrimaryImageVisibility(_loc9_,this.m_primaryLegalState);
               if(this.m_primaryLegalState != this.m_previousPrimaryLegalState || this.m_previousIsPrimaryHolsteredOnBack != _loc9_)
               {
                  this.setStateIcon(this.m_view.iconPri_mc,0.46,this.m_primaryLegalState,_loc9_ && ControlsMain.isVrModeActive());
                  this.m_previousPrimaryLegalState = this.m_primaryLegalState;
                  this.m_previousIsPrimaryHolsteredOnBack = _loc9_;
               }
            }
         }
         else
         {
            this.m_primaryWeaponHolstered = false;
            this.pulsateReloadMc(0,false);
            this.m_view.reloadHolder.reload_mc.visible = false;
            this.m_view.ammoDisplayContainer.ammoDisplay.visible = false;
            this.setStateIcon(this.m_view.iconPri_mc,0.46,LEGALSTATE_CLEAR);
            this.m_previousPrimaryLegalState = LEGALSTATE_CLEAR;
            this.m_previousIsPrimaryHolsteredOnBack = false;
            this.m_lastWeaponData.bHasItemToShow = false;
            this.m_finalWeaponWasDropped = true;
            this.m_primaryLoader.visible = false;
            this.m_primaryIsShown = false;
         }
         if(_loc3_.bHasItemToShow && _loc2_.icon != _loc3_.icon && Boolean(param1.bShowHolstered))
         {
            this.m_secondaryIsShown = true;
            if(_loc6_)
            {
               this.setSecondaryIcon(_loc3_.icon);
            }
            if(_loc3_.bIllegal != this.m_lastBackData.bIllegal || _loc3_.bSuspicious != this.m_lastBackData.bSuspicious || _loc6_)
            {
               if(Boolean(_loc3_.bIllegal) && Boolean(param1.bShowHolstered))
               {
                  this.m_secondaryLegalState = LEGALSTATE_ILLEGAL;
               }
               else if(Boolean(_loc3_.bSuspicious) && Boolean(param1.bShowHolstered))
               {
                  this.m_secondaryLegalState = LEGALSTATE_SUSPICIOUS;
               }
               else
               {
                  this.m_secondaryLegalState = LEGALSTATE_CLEAR;
               }
               this.setStateIcon(this.m_view.iconSec_mc,0.23,this.m_secondaryLegalState,ControlsMain.isVrModeActive());
               this.m_secondaryLoader.visible = true;
            }
         }
         else if(this.m_lastBackData.bHasItemToShow)
         {
            this.m_secondaryLoader.visible = false;
            this.setStateIcon(this.m_view.iconSec_mc,0.23,LEGALSTATE_CLEAR);
            this.m_secondaryLegalState = LEGALSTATE_CLEAR;
            _loc3_.bHasItemToShow = false;
            this.m_secondaryIsShown = false;
         }
         else
         {
            this.m_secondaryLoader.visible = false;
            _loc3_.bHasItemToShow = false;
            this.m_secondaryIsShown = false;
         }
         if(Boolean(_loc4_.bHasItemToShow) && Boolean(_loc4_.bIllegal))
         {
            this.m_leftHandIsShown = true;
            if(_loc7_)
            {
               this.setLeftHandIcon(_loc4_.icon);
            }
            if(_loc4_.bIllegal != this.m_lastLeftHandData.bIllegal || _loc4_.bSuspicious != this.m_lastLeftHandData.bSuspicious || _loc7_)
            {
               if(_loc4_.bIllegal)
               {
                  this.m_leftHandLegalState = LEGALSTATE_ILLEGAL;
               }
               else if(_loc4_.bSuspicious)
               {
                  this.m_leftHandLegalState = LEGALSTATE_SUSPICIOUS;
               }
               else
               {
                  this.m_leftHandLegalState = LEGALSTATE_CLEAR;
               }
               this.setStateIcon(this.m_view.iconLeftHand_mc,0.23,this.m_leftHandLegalState);
               this.m_leftHandLoader.visible = true;
            }
         }
         else if(this.m_lastLeftHandData.bHasItemToShow)
         {
            this.m_leftHandLoader.visible = false;
            this.setStateIcon(this.m_view.iconLeftHand_mc,0.23,LEGALSTATE_CLEAR);
            this.m_leftHandLegalState = LEGALSTATE_CLEAR;
            this.m_lastLeftHandData.bHasItemToShow = false;
            this.m_leftHandIsShown = false;
         }
         else
         {
            this.m_leftHandLoader.visible = false;
            this.m_lastLeftHandData.bHasItemToShow = false;
            this.m_leftHandIsShown = false;
         }
         if(_loc2_.bHasItemToShow)
         {
            this.m_lastWeaponData = _loc2_;
         }
         if(_loc3_.bHasItemToShow)
         {
            this.m_lastBackData = _loc3_;
         }
         if(_loc4_.bHasItemToShow)
         {
            this.m_lastLeftHandData = _loc4_;
         }
      }
      
      private function unholsterWeapon() : void
      {
         this.m_primaryWeaponHolstered = false;
         this.m_view.ammoDisplayContainer.visible = true;
         this.m_primaryLoader.visible = true;
         Animate.legacyTo(this.m_view.ammoDisplayContainer,0.3,{"alpha":1},Animate.ExpoOut);
         this.setHolsterEffect(false,this.m_view.imageHolderPri_mc);
      }
      
      private function holsterWeapon(param1:Boolean) : void
      {
         this.m_primaryWeaponHolstered = true;
         this.m_primaryLoader.visible = !param1;
         this.m_view.ammoDisplayContainer.visible = !param1;
         if(!param1)
         {
            this.m_reloadClipShownWhileHolster = true;
            this.pulsateReloadMc(0,false);
            this.m_view.reloadHolder.reload_mc.visible = false;
            Animate.legacyTo(this.m_view.ammoDisplayContainer,0.3,{"alpha":0},Animate.ExpoOut);
            this.setHolsterEffect(true,this.m_view.imageHolderPri_mc);
         }
         else
         {
            this.m_view.imageHolderPri_mc.alpha = 0;
         }
      }
      
      private function setWeaponIcon(param1:String) : void
      {
         if(this.m_currentPrimaryImage != param1)
         {
            this.loadPrimaryImage(param1);
            this.m_currentPrimaryImage = param1;
         }
      }
      
      private function setSecondaryIcon(param1:String) : void
      {
         if(this.m_currentSecondaryImage != param1)
         {
            this.loadSecondaryImage(param1);
            this.m_currentSecondaryImage = param1;
         }
      }
      
      private function setLeftHandIcon(param1:String) : void
      {
         if(this.m_currentLeftHandImage != param1)
         {
            this.loadLeftHandImage(param1);
            this.m_currentLeftHandImage = param1;
         }
      }
      
      public function setWeaponAmmo(param1:Number) : void
      {
      }
      
      private function setWeaponAmmoInfo(param1:int, param2:int, param3:int, param4:Number, param5:int, param6:Boolean = true, param7:Boolean = false, param8:Number = 0) : void
      {
         var nAmmoRemaining:int = param1;
         var nAmmoTotal:int = param2;
         var nAmmoInClip:int = param3;
         var nWeaponType:Number = param4;
         var nDisplayMode:int = param5;
         var bCanReload:Boolean = param6;
         var bIsReloading:Boolean = param7;
         var fReloadDuration:Number = param8;
         if(this.m_currentAmmoInGun != nAmmoRemaining || this.m_currentAmmoInStore != nAmmoTotal || this.m_currentAmmoInClip != nAmmoInClip || this.m_currentAmmoType != nWeaponType || this.m_isReloading != bIsReloading || this.m_reloadClipShownWhileHolster || this.m_finalWeaponWasDropped)
         {
            if(this.m_primaryWeaponHolstered)
            {
               return;
            }
            if(this.m_isReloading != bIsReloading)
            {
               this.m_isReloading = bIsReloading;
               if(this.m_isReloading)
               {
               }
            }
            this.m_reloadClipShownWhileHolster = false;
            this.m_finalWeaponWasDropped = false;
            this.m_view.reloadHolder.reload_mc.visible = false;
            this.pulsateReloadMc(0,false);
            this.m_reloadUrgent = false;
            if(nAmmoTotal > 1 && nAmmoRemaining < 0)
            {
               this.m_view.ammoDisplayContainer.ammoDisplay.visible = true;
               this.m_view.ammoDisplayContainer.ammoDisplay.ammoCurrent_txt.visible = true;
               this.m_view.ammoDisplayContainer.ammoDisplay.ammoTotal_txt.visible = false;
               MenuUtils.setupText(this.m_view.ammoDisplayContainer.ammoDisplay.ammoCurrent_txt,"x" + nAmmoTotal.toString(),36,MenuConstants.FONT_TYPE_BOLD,MenuConstants.FontColorGreyUltraLight);
               MenuUtils.setupText(this.m_view.ammoDisplayContainer.ammoDisplay.ammoTotal_txt,"",18,MenuConstants.FONT_TYPE_MEDIUM,MenuConstants.FontColorGreyUltraLight);
               this.m_view.ammoDisplayContainer.ammoDisplay.ammoTotal_txt.x = this.m_view.ammoDisplayContainer.ammoDisplay.ammoCurrent_txt.textWidth + 2;
               if(!ControlsMain.isVrModeActive())
               {
                  this.m_view.ammoDisplayContainer.x = (120 - this.m_primaryLoader.width) / 2 - 120 - (this.m_view.ammoDisplayContainer.ammoDisplay.ammoTotal_txt.x + this.m_view.ammoDisplayContainer.ammoDisplay.ammoTotal_txt.textWidth) - 16;
               }
            }
            else if(nAmmoRemaining >= 0 && nAmmoTotal >= 0)
            {
               this.m_view.ammoDisplayContainer.ammoDisplay.visible = true;
               this.m_view.ammoDisplayContainer.ammoDisplay.ammoCurrent_txt.visible = true;
               this.m_view.ammoDisplayContainer.ammoDisplay.ammoTotal_txt.visible = true;
               MenuUtils.setupText(this.m_view.ammoDisplayContainer.ammoDisplay.ammoCurrent_txt,nAmmoRemaining.toString(),36,MenuConstants.FONT_TYPE_BOLD,MenuConstants.FontColorGreyUltraLight);
               if(bCanReload)
               {
                  MenuUtils.setupText(this.m_view.ammoDisplayContainer.ammoDisplay.ammoTotal_txt,"/" + nAmmoTotal.toString(),18,MenuConstants.FONT_TYPE_MEDIUM,MenuConstants.FontColorGreyUltraLight);
               }
               else
               {
                  MenuUtils.setupText(this.m_view.ammoDisplayContainer.ammoDisplay.ammoTotal_txt,"",18,MenuConstants.FONT_TYPE_MEDIUM,MenuConstants.FontColorGreyUltraLight);
               }
               this.m_view.ammoDisplayContainer.ammoDisplay.ammoTotal_txt.x = this.m_view.ammoDisplayContainer.ammoDisplay.ammoCurrent_txt.textWidth + 2;
               if(!ControlsMain.isVrModeActive())
               {
                  this.m_view.ammoDisplayContainer.x = (120 - this.m_primaryLoader.width) / 2 - 120 - (this.m_view.ammoDisplayContainer.ammoDisplay.ammoTotal_txt.x + this.m_view.ammoDisplayContainer.ammoDisplay.ammoTotal_txt.textWidth) - 16;
               }
               if(nAmmoTotal > 0)
               {
                  if(nAmmoRemaining == 1 && nAmmoInClip != 1)
                  {
                     if(ControlsMain.isVrModeActive())
                     {
                        this.m_view.reloadHolder.reload_mc.visible = true;
                        this.pulsateReloadMc(0.3,true);
                     }
                     else
                     {
                        Animate.delay(this,nDisplayMode == 1 ? 0 : 1.2,function():void
                        {
                           m_view.reloadHolder.reload_mc.visible = true;
                           pulsateReloadMc(0.3,true);
                        });
                     }
                  }
                  else if(nAmmoRemaining == 0)
                  {
                     if(ControlsMain.isVrModeActive())
                     {
                        this.m_reloadUrgent = true;
                        this.m_view.reloadHolder.reload_mc.visible = true;
                        this.pulsateReloadMc(0.15,true);
                     }
                     else
                     {
                        Animate.delay(this,nDisplayMode == 1 ? 0 : 1.2,function():void
                        {
                           m_reloadUrgent = true;
                           m_view.reloadHolder.reload_mc.visible = true;
                           pulsateReloadMc(0.3,true);
                        });
                     }
                  }
               }
            }
            else
            {
               this.m_view.ammoDisplayContainer.ammoDisplay.ammoCurrent_txt.visible = false;
               this.m_view.ammoDisplayContainer.ammoDisplay.ammoTotal_txt.visible = false;
            }
            this.m_currentAmmoInGun = nAmmoRemaining;
            this.m_currentAmmoInStore = nAmmoTotal;
            this.m_currentAmmoInClip = nAmmoInClip;
            this.m_currentAmmoType = nWeaponType;
         }
      }
      
      private function pulsateReloadMc(param1:Number, param2:Boolean) : void
      {
         this.m_reloadAnimIsRunning = false;
         Animate.kill(this);
         Animate.kill(this.m_view.reloadHolder.reload_mc.reload_txt);
         Animate.kill(this.m_view.reloadHolder.reload_mc.bg);
         MenuUtils.removeTint(this.m_view.reloadHolder.reload_mc.bg);
         if(this.m_reloadUrgent)
         {
            MenuUtils.setTintColor(this.m_view.reloadHolder.reload_mc.reload_txt,MenuUtils.TINT_COLOR_WHITE,false);
         }
         else
         {
            MenuUtils.setTintColor(this.m_view.reloadHolder.reload_mc.reload_txt,MenuUtils.TINT_COLOR_ULTRA_DARK_GREY,false);
         }
         this.m_view.reloadHolder.reload_mc.bg.alpha = 1;
         if(param2)
         {
            this.m_reloadAnimIsRunning = true;
            if(this.m_reloadUrgent)
            {
               if(this.m_sniperModeIsEntered)
               {
                  this.m_view.reloadHolder.alpha = 0;
               }
               MenuUtils.setTintColor(this.m_view.reloadHolder.reload_mc.bg,MenuUtils.TINT_COLOR_MAGENTA_DARK,false);
            }
            Animate.delay(this,param1,this.pulsateFadeIn,param1);
         }
      }
      
      private function pulsateFadeIn(param1:Number) : void
      {
         if(this.m_reloadUrgent)
         {
            MenuUtils.setTintColor(this.m_view.reloadHolder.reload_mc.reload_txt,MenuUtils.TINT_COLOR_MAGENTA_DARK,false);
         }
         else
         {
            MenuUtils.setTintColor(this.m_view.reloadHolder.reload_mc.reload_txt,MenuUtils.TINT_COLOR_WHITE,false);
         }
         this.m_view.reloadHolder.reload_mc.bg.alpha = 0;
         Animate.delay(this,param1,this.pulsateFadeOut,param1);
      }
      
      private function pulsateFadeOut(param1:Number) : void
      {
         if(this.m_reloadUrgent)
         {
            MenuUtils.setTintColor(this.m_view.reloadHolder.reload_mc.reload_txt,MenuUtils.TINT_COLOR_WHITE,false);
         }
         else
         {
            MenuUtils.setTintColor(this.m_view.reloadHolder.reload_mc.reload_txt,MenuUtils.TINT_COLOR_ULTRA_DARK_GREY,false);
         }
         this.m_view.reloadHolder.reload_mc.bg.alpha = 1;
         Animate.delay(this,param1,this.pulsateFadeIn,param1);
      }
      
      public function setPointShooing(param1:Number) : void
      {
      }
      
      private function setStateIcon(param1:MovieClip, param2:Number, param3:int, param4:Boolean = false) : void
      {
         Animate.kill(param1);
         param1.alpha = 0;
         if(param3 != LEGALSTATE_CLEAR)
         {
            if(param3 == LEGALSTATE_ILLEGAL)
            {
               param1.gotoAndStop("visarmed");
            }
            else
            {
               param1.gotoAndStop("susarmed");
            }
            param1.scaleX = param1.scaleY = param2 * 1.25;
            Animate.legacyTo(param1,0.3,{
               "scaleX":param2,
               "scaleY":param2,
               "alpha":1
            },Animate.ExpoOut);
            if(param4)
            {
               this.pulsateStateIcon_StepA(param1,param2);
            }
         }
      }
      
      private function pulsateStateIcon_StepA(param1:MovieClip, param2:Number) : void
      {
         Animate.addFromTo(param1,0.3,0.4,{
            "scaleX":param2,
            "scaleY":param2,
            "alpha":1
         },{
            "scaleX":param2 * 2,
            "scaleY":param2 * 2,
            "alpha":0
         },Animate.ExpoOut,this.pulsateStateIcon_StepB,param1,param2);
      }
      
      private function pulsateStateIcon_StepB(param1:MovieClip, param2:Number) : void
      {
         Animate.addFromTo(param1,0.3,0,{
            "scaleX":param2 / 2,
            "scaleY":param2 / 2,
            "alpha":0
         },{
            "scaleX":param2,
            "scaleY":param2,
            "alpha":1
         },Animate.ExpoOut,this.pulsateStateIcon_StepA,param1,param2);
      }
      
      private function setHolsterEffect(param1:Boolean, param2:MovieClip) : void
      {
         var _loc6_:Number = NaN;
         var _loc7_:GlowFilter = null;
         var _loc3_:Color = new Color();
         var _loc4_:Number = 0.3;
         var _loc5_:Number = 1;
         if(ControlsMain.isVrModeActive())
         {
            _loc5_ = 0;
         }
         if(param1)
         {
            Animate.legacyTo(param2,0.3,{"alpha":_loc4_},Animate.ExpoOut);
            _loc3_.setTint(16777215,1);
            if(!ControlsMain.isVrModeActive())
            {
               _loc6_ = Math.max(1,this.m_fScaleAccum) * PX_BLUR;
               _loc7_ = new GlowFilter();
               _loc7_.color = 16777215;
               _loc7_.blurX = _loc7_.blurY = _loc6_;
               _loc7_.knockout = true;
               _loc7_.strength = 20;
               param2.filters = [_loc7_];
            }
         }
         else
         {
            _loc3_.setTint(16777215,1);
            param2.filters = [];
            Animate.legacyTo(param2,0.3,{"alpha":_loc5_},Animate.ExpoOut);
         }
         param2.transform.colorTransform = _loc3_;
      }
      
      private function loadPrimaryImage(param1:String) : void
      {
         var maxWidth:Number = NaN;
         var maxHeight:Number = NaN;
         var reducedWidth:Number = NaN;
         var appliedHeight:Number = NaN;
         var imagePath:String = param1;
         Animate.kill(this.m_primaryLoader);
         this.m_view.ammoDisplayContainer.ammoDisplay.visible = false;
         if(this.m_primaryLoader != null)
         {
            this.m_primaryLoader.cancel();
            this.m_view.imageHolderPri_mc.removeChild(this.m_primaryLoader);
            this.m_primaryLoader = null;
         }
         this.m_primaryLoader = new ImageLoader();
         this.m_view.imageHolderPri_mc.addChild(this.m_primaryLoader);
         maxWidth = 190;
         maxHeight = 190;
         reducedWidth = 120;
         appliedHeight = maxHeight;
         if(ControlsMain.isVrModeActive())
         {
            appliedHeight = 95;
         }
         this.m_primaryLoader.rotation = 0;
         this.m_primaryLoader.scaleX = this.m_primaryLoader.scaleY = 1;
         this.m_primaryLoader.loadImage(imagePath,function():void
         {
            var _loc1_:Boolean = false;
            if(m_primaryLoader.width > m_primaryLoader.height)
            {
               m_primaryLoader.rotation = -90;
               _loc1_ = true;
            }
            m_primaryLoader.width = reducedWidth;
            m_primaryLoader.scaleY = m_primaryLoader.scaleX;
            if(m_primaryLoader.height > appliedHeight)
            {
               m_primaryLoader.height = appliedHeight;
               m_primaryLoader.scaleX = m_primaryLoader.scaleY;
            }
            m_primaryLoader.x = maxWidth / 2 - m_primaryLoader.width - (reducedWidth - m_primaryLoader.width) / 2;
            if(_loc1_)
            {
               m_primaryLoader.y = m_primaryLoader.height / 2 + (maxHeight - m_primaryLoader.height) / 2;
            }
            else
            {
               m_primaryLoader.y = m_primaryLoader.height / -2 + (maxHeight - m_primaryLoader.height) / 2;
            }
            if(!ControlsMain.isVrModeActive())
            {
               m_view.ammoDisplayContainer.x = (120 - m_primaryLoader.width) / 2 - 120 - (m_view.ammoDisplayContainer.ammoDisplay.ammoTotal_txt.x + m_view.ammoDisplayContainer.ammoDisplay.ammoTotal_txt.textWidth) - 16;
            }
            m_view.ammoDisplayContainer.ammoDisplay.visible = true;
         });
      }
      
      private function loadSecondaryImage(param1:String) : void
      {
         var maxWidth:Number = NaN;
         var maxHeight:Number = NaN;
         var appliedHeight:Number = NaN;
         var imagePath:String = param1;
         Animate.kill(this.m_secondaryLoader);
         if(this.m_secondaryLoader != null)
         {
            this.m_secondaryLoader.cancel();
            this.m_view.imageHolderSec_mc.removeChild(this.m_secondaryLoader);
            this.m_secondaryLoader = null;
         }
         this.m_secondaryLoader = new ImageLoader();
         this.m_view.imageHolderSec_mc.addChild(this.m_secondaryLoader);
         maxWidth = 70;
         maxHeight = 140;
         appliedHeight = maxHeight;
         if(ControlsMain.isVrModeActive())
         {
            appliedHeight = 70;
         }
         this.m_secondaryLoader.rotation = 0;
         this.m_secondaryLoader.scaleX = this.m_secondaryLoader.scaleY = 1;
         this.m_secondaryLoader.loadImage(imagePath,function():void
         {
            var _loc1_:Boolean = false;
            if(m_secondaryLoader.width > m_secondaryLoader.height)
            {
               m_secondaryLoader.rotation = -90;
               _loc1_ = true;
            }
            m_secondaryLoader.width = maxWidth;
            m_secondaryLoader.scaleY = m_secondaryLoader.scaleX;
            if(m_secondaryLoader.height > appliedHeight)
            {
               m_secondaryLoader.height = appliedHeight;
               m_secondaryLoader.scaleX = m_secondaryLoader.scaleY;
            }
            m_secondaryLoader.x = -m_secondaryLoader.width - 4;
            var _loc2_:Number = m_secondaryLoader.height;
            if(ControlsMain.isVrModeActive())
            {
               _loc2_ = maxHeight;
            }
            if(_loc1_)
            {
               m_secondaryLoader.y = _loc2_;
            }
            else
            {
               m_secondaryLoader.y = -_loc2_;
            }
         });
      }
      
      private function loadLeftHandImage(param1:String) : void
      {
         var maxWidth:Number = NaN;
         var maxHeight:Number = NaN;
         var imagePath:String = param1;
         Animate.kill(this.m_leftHandLoader);
         if(this.m_leftHandLoader != null)
         {
            this.m_leftHandLoader.cancel();
            this.m_view.imageHolderLeftHand_mc.removeChild(this.m_leftHandLoader);
            this.m_leftHandLoader = null;
         }
         this.m_leftHandLoader = new ImageLoader();
         this.m_view.imageHolderLeftHand_mc.addChild(this.m_leftHandLoader);
         maxWidth = 50;
         maxHeight = 50;
         this.m_leftHandLoader.rotation = 0;
         this.m_leftHandLoader.scaleX = this.m_leftHandLoader.scaleY = 1;
         this.m_leftHandLoader.loadImage(imagePath,function():void
         {
            var _loc1_:Boolean = false;
            if(m_leftHandLoader.width > m_leftHandLoader.height)
            {
               m_leftHandLoader.rotation = -90;
               _loc1_ = true;
            }
            m_leftHandLoader.width = maxWidth;
            m_leftHandLoader.scaleY = m_leftHandLoader.scaleX;
            if(m_leftHandLoader.height > maxHeight)
            {
               m_leftHandLoader.height = maxHeight;
               m_leftHandLoader.scaleX = m_leftHandLoader.scaleY;
            }
            m_leftHandLoader.x = -m_leftHandLoader.width - 4;
            if(_loc1_)
            {
               m_leftHandLoader.y = m_leftHandLoader.height - 5;
            }
            else
            {
               m_leftHandLoader.y = m_leftHandLoader.height - 45;
            }
         });
      }
      
      private function updatePrimaryImageVisibility(param1:Boolean, param2:int) : void
      {
         if(!ControlsMain.isVrModeActive())
         {
            this.m_view.imageHolderPri_mc.visible = true;
            return;
         }
         if(!param1)
         {
            this.m_view.imageHolderPri_mc.visible = false;
            return;
         }
         this.m_view.imageHolderPri_mc.visible = param2 != LEGALSTATE_CLEAR;
      }
      
      public function showWeaponBackdrop() : void
      {
         if(ControlsMain.isVrModeActive())
         {
            return;
         }
         if(this.m_primaryIsShown || this.m_secondaryIsShown || this.m_leftHandIsShown)
         {
            this.m_weaponBackground.visible = true;
         }
      }
      
      public function hideWeaponBackdrop() : void
      {
         this.m_weaponBackground.visible = false;
      }
      
      public function setActionSelectionMode() : void
      {
         Animate.kill(this.m_view);
         if(this.m_primaryIsShown || this.m_secondaryIsShown || this.m_leftHandIsShown)
         {
            Animate.to(this.m_view,0.2,0,{"alpha":0.3},Animate.ExpoOut);
         }
      }
      
      public function unsetActionSelectionMode() : void
      {
         Animate.kill(this.m_view);
         if(this.m_primaryIsShown || this.m_secondaryIsShown || this.m_leftHandIsShown)
         {
            Animate.to(this.m_view,0.2,0,{"alpha":1},Animate.ExpoOut);
         }
      }
      
      private function xAlignSecondary() : void
      {
         this.m_secondaryLoader.x = this.m_primaryLoader.x + this.m_primaryLoader.width / this.m_view.imageHolderPri_mc.scaleX;
         this.m_view.imageHolderSec_mc.x = this.m_view.imageHolderPri_mc.x / this.m_view.imageHolderPri_mc.scaleX;
      }
      
      public function EnterSniperMode() : void
      {
         this.m_sniperModeIsEntered = true;
         if(this.m_reloadAnimIsRunning && this.m_reloadUrgent)
         {
            this.m_view.reloadHolder.alpha = 0;
         }
      }
      
      public function ExitSniperMode() : void
      {
         this.m_sniperModeIsEntered = false;
         this.m_view.reloadHolder.alpha = 1;
      }
      
      override public function onSetVisible(param1:Boolean) : void
      {
         this.visible = param1;
      }
      
      override public function onSetSize(param1:Number, param2:Number) : void
      {
         var _loc4_:DisplayObject = null;
         var _loc5_:Array = null;
         var _loc6_:GlowFilter = null;
         var _loc7_:Number = NaN;
         if(ControlsMain.isVrModeActive())
         {
            return;
         }
         this.m_fScaleAccum = 1;
         var _loc3_:DisplayObject = this;
         do
         {
            this.m_fScaleAccum *= _loc3_.scaleX;
            _loc3_ = _loc3_.parent;
         }
         while(_loc3_ != _loc3_.root);
         
         for each(_loc4_ in [this.m_view.imageHolderSec_mc,this.m_view.imageHolderPri_mc])
         {
            _loc5_ = _loc4_.filters;
            if(!(_loc5_ == null || _loc5_.length == 0))
            {
               _loc6_ = _loc5_[0] as GlowFilter;
               if(_loc6_ != null)
               {
                  _loc7_ = Math.max(1,this.m_fScaleAccum) * PX_BLUR;
                  _loc6_.blurX = _loc6_.blurY = _loc7_;
                  _loc4_.filters = _loc5_;
               }
            }
         }
      }
   }
}

