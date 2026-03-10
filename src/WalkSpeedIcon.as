package hud
{
   import common.BaseControl;
   
   public class WalkSpeedIcon extends BaseControl
   {
      
      private var m_view:WalkSpeedIconView;
      
      public function WalkSpeedIcon()
      {
         super();
         this.m_view = new WalkSpeedIconView();
         this.m_view.bg.alpha = 0;
         this.m_view.visible = false;
         this.m_view.scaleX = 0;
         this.m_view.scaleY = 0;
         addChild(this.m_view);
      }
      
      public function onSetData(param1:Object) : void
      {
      }
   }
}

