(this.webpackJsonpresume=this.webpackJsonpresume||[]).push([[0],{43:function(e,t,n){},44:function(e,t,n){},51:function(e,t,n){"use strict";n.r(t);var a=n(0),c=n.n(a),o=n(20),r=n.n(o),i=n(30),s=n(6),u=n(16),l=n(17),d=n(19),h=n(18),j=n(55),m=n(53),f=n(56),b=n(1),g=function(e){Object(d.a)(n,e);var t=Object(h.a)(n);function n(){return Object(u.a)(this,n),t.apply(this,arguments)}return Object(l.a)(n,[{key:"render",value:function(){return Object(b.jsx)("header",{className:"fixed-top",style:{},children:Object(b.jsx)(j.a,{bg:"dark",variant:"dark",expand:"lg",sticky:"top",id:"sidebar",children:Object(b.jsxs)(m.a,{fluid:!0,style:{marginLeft:40,marginRight:40},children:[Object(b.jsx)(j.a.Toggle,{"aria-controls":"basic-navbar-nav"}),Object(b.jsx)(j.a.Brand,{href:"#home",children:"Logo"}),Object(b.jsx)(j.a.Collapse,{id:"sidebar",className:"justify-content-end",children:Object(b.jsxs)(f.a,{defaultActiveKey:"#home",children:[Object(b.jsx)(f.a.Link,{href:"#home",children:"Home"}),Object(b.jsx)(f.a.Link,{href:"#About",children:"About Me"}),Object(b.jsx)(f.a.Link,{href:"#ContactMe",children:"Contact Me"})]})})]})})})}}]),n}(a.Component),v=function(e){Object(d.a)(n,e);var t=Object(h.a)(n);function n(){return Object(u.a)(this,n),t.apply(this,arguments)}return Object(l.a)(n,[{key:"render",value:function(){return Object(b.jsx)("div",{})}}]),n}(a.Component),p=(n(43),function(e){return Object(b.jsxs)(c.a.Fragment,{children:[Object(b.jsx)(g,{style:{flex:1}}),e.children,Object(b.jsx)(v,{})]})});var O=function(){},x=n(54),y=function(e){Object(d.a)(n,e);var t=Object(h.a)(n);function n(){var e;return Object(u.a)(this,n),(e=t.call(this)).updateImage=function(t,n,a){0!==n&&null!==n||(n=1),(t=e.getImage(n)).onload=function(){a.drawImage(t,0,0)}},e.canvasRef=a.createRef,e}return Object(l.a)(n,[{key:"getImage",value:function(e){var t,n="/myResume/img/img"+e.toString().padStart(5,0)+".jpeg",a=new Image;return(t=n,new Promise((function(e){var n=new Image;n.src=t,n.onload=function(){return e(t)}}))).then((function(e){a.src=n,console.log("resolved")})).catch((function(e){return console.error(e)})),a}},{key:"showImage",value:function(){var e=this.refs.canvas,t=new Image;(t=this.getImage(1)).onload=function(){var n=e.getContext("2d");e.width=t.width,e.height=t.height,console.log(t.width,t.height),n.drawImage(t,0,0)}}},{key:"updateCanvas",value:function(){var e=this.refs.canvas,t=new Image;t=this.getImage(1);var n=e.getContext("2d"),a=document.documentElement,c=a.scrollTop/(a.scrollHeight-window.innerHeight),o=Math.min(3689,Math.floor(3690*c));this.updateImage(t,o+1,n),console.log(o)}},{key:"componentDidMount",value:function(){var e=this;this.showImage(),document.onscroll=function(){requestAnimationFrame((function(){e.updateCanvas()}))}}},{key:"componentDidUpdate",value:function(){document.scrollTop=0}},{key:"componentWillUnmount",value:function(){document.scrollTop=0}},{key:"render",value:function(){return Object(b.jsx)(m.a,{fluid:!0,style:{marginTop:"80px"},children:Object(b.jsx)(x.a,{children:Object(b.jsx)("canvas",{ref:"canvas",width:"1158",height:"770"})})})}}]),n}(a.Component);var k=function(){};n(44);var w=function(){return Object(b.jsx)("div",{children:Object(b.jsx)(i.a,{children:Object(b.jsx)(p,{children:Object(b.jsxs)(s.c,{children:[Object(b.jsx)(s.a,{path:"/",component:y}),Object(b.jsx)(s.a,{path:"/About",component:O}),Object(b.jsx)(s.a,{path:"/ContactMe",component:k})]})})})})};r.a.render(Object(b.jsx)(w,{}),document.getElementById("root"))}},[[51,1,2]]]);
//# sourceMappingURL=main.91ff3e77.chunk.js.map