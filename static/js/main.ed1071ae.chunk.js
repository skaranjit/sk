(this.webpackJsonpresume=this.webpackJsonpresume||[]).push([[0],{45:function(e,t,n){},47:function(e,t,n){},54:function(e,t,n){"use strict";n.r(t);var a=n(0),c=n.n(a),r=n(20),o=n.n(r),i=n(32),s=n(6),u=n(16),l=n(17),d=n(19),h=n(18),j=n(58),m=n(56),f=n(59),g=n(1),b=function(e){Object(d.a)(n,e);var t=Object(h.a)(n);function n(){return Object(u.a)(this,n),t.apply(this,arguments)}return Object(l.a)(n,[{key:"render",value:function(){return Object(g.jsx)("header",{className:"fixed-top",style:{},children:Object(g.jsx)(j.a,{bg:"dark",variant:"dark",expand:"lg",sticky:"top",id:"sidebar",children:Object(g.jsxs)(m.a,{fluid:!0,style:{marginLeft:40,marginRight:40},children:[Object(g.jsx)(j.a.Toggle,{"aria-controls":"basic-navbar-nav"}),Object(g.jsx)(j.a.Brand,{href:"#home",children:"Logo"}),Object(g.jsx)(j.a.Collapse,{id:"sidebar",className:"justify-content-end",children:Object(g.jsxs)(f.a,{defaultActiveKey:"#home",children:[Object(g.jsx)(f.a.Link,{href:"#home",children:"Home"}),Object(g.jsx)(f.a.Link,{href:"#About",children:"About Me"}),Object(g.jsx)(f.a.Link,{href:"#ContactMe",children:"Contact Me"})]})})]})})})}}]),n}(a.Component),p=function(e){Object(d.a)(n,e);var t=Object(h.a)(n);function n(){return Object(u.a)(this,n),t.apply(this,arguments)}return Object(l.a)(n,[{key:"render",value:function(){return Object(g.jsx)("div",{})}}]),n}(a.Component),v=(n(45),function(e){return Object(g.jsxs)(c.a.Fragment,{children:[Object(g.jsx)(b,{style:{flex:1}}),e.children,Object(g.jsx)(p,{})]})});var O=function(){},x=n(26),k=n.n(x),w=n(31),y=n(57),I=function(e){Object(d.a)(n,e);var t=Object(h.a)(n);function n(){var e;return Object(u.a)(this,n),(e=t.call(this)).updateImage=function(t,n,a){0!==n&&null!==n||(n=1),(t=e.getImage(n)).onload=function(){a.drawImage(t,0,0)}},e.getAllImg=Object(w.a)(k.a.mark((function t(){var n,a;return k.a.wrap((function(t){for(;;)switch(t.prev=t.next){case 0:n=0;case 1:if(3690==n){t.next=9;break}return n++,new Image,a=e.getImage(n),t.next=7,a.onload;case 7:t.next=1;break;case 9:case"end":return t.stop()}}),t)}))),e.canvasRef=a.createRef,e}return Object(l.a)(n,[{key:"getImage",value:function(e){var t,n="/myResume/img/img"+e.toString().padStart(5,0)+".jpeg",a=new Image;return(t=n,new Promise((function(e){var n=new Image;n.src=t,n.onload=function(){return e(t)}}))).then((function(e){a.src=n,console.log("resolved")})).catch((function(e){return console.error(e)})),a}},{key:"showImage",value:function(){var e=this.refs.canvas,t=new Image;(t=this.getImage(1)).onload=function(){var n=e.getContext("2d");e.width=t.width,e.height=t.height,console.log(t.width,t.height),n.drawImage(t,0,0)}}},{key:"updateCanvas",value:function(){var e=this.refs.canvas,t=new Image;t=this.getImage(1);var n=e.getContext("2d"),a=document.documentElement,c=a.scrollTop/(a.scrollHeight-window.innerHeight),r=Math.min(3689,Math.floor(3690*c));this.updateImage(t,r+1,n),console.log(r)}},{key:"componentDidMount",value:function(){var e=this;this.getAllImg(),this.showImage(),document.onscroll=function(){requestAnimationFrame((function(){e.updateCanvas()}))}}},{key:"componentDidUpdate",value:function(){document.scrollTop=0}},{key:"componentWillUnmount",value:function(){document.scrollTop=0}},{key:"render",value:function(){return Object(g.jsx)(m.a,{fluid:!0,style:{marginTop:"80px"},children:Object(g.jsx)(y.a,{children:Object(g.jsx)("canvas",{ref:"canvas",width:"1158",height:"770"})})})}}]),n}(a.Component);var C=function(){};n(47);var A=function(){return Object(g.jsx)("div",{children:Object(g.jsx)(i.a,{children:Object(g.jsx)(v,{children:Object(g.jsxs)(s.c,{children:[Object(g.jsx)(s.a,{path:"/",component:I}),Object(g.jsx)(s.a,{path:"/About",component:O}),Object(g.jsx)(s.a,{path:"/ContactMe",component:C})]})})})})};o.a.render(Object(g.jsx)(A,{}),document.getElementById("root"))}},[[54,1,2]]]);
//# sourceMappingURL=main.ed1071ae.chunk.js.map