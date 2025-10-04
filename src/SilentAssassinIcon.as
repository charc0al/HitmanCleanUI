package hud
{
   import common.BaseControl;
   
   public class SilentAssassinIcon extends BaseControl
   {
      
      private var m_view:SAIconView;
      
      public function SilentAssassinIcon()
      {
         super();
         this.m_view = new SAIconView();
         this.m_view.bg.alpha = 0;
         this.m_view.gotoAndStop("active");
         addChild(this.m_view);
      }
      
      public function onSAStatusChanged(param1:Boolean, param2:Boolean) : void
      {
         if(param1)
         {
            this.m_view.iconMc.gotoAndStop("inactive");
            this.m_view.iconMc.visible = true;
         }
         else if(param2)
         {
            this.m_view.iconMc.gotoAndStop("recovery_recorded");
            this.m_view.iconMc.visible = true;
         }
         else
         {
            this.m_view.iconMc.visible = false;
         }
      }
   }
}

