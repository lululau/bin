FasdUAS 1.101.10   ��   ��    k             l     ��������  ��  ��        l     �� 	 
��   	    tell application "Safari"    
 �   4   t e l l   a p p l i c a t i o n   " S a f a r i "      l     ��  ��    w q 	set title to quoted form of (do JavaScript "encodeURIComponent(document.title)" in current tab of first window)     �   �   	 s e t   t i t l e   t o   q u o t e d   f o r m   o f   ( d o   J a v a S c r i p t   " e n c o d e U R I C o m p o n e n t ( d o c u m e n t . t i t l e ) "   i n   c u r r e n t   t a b   o f   f i r s t   w i n d o w )      l     ��  ��    | v 	set link to quoted form of (do JavaScript "encodeURIComponent(window.location.href)" in current tab of first window)     �   �   	 s e t   l i n k   t o   q u o t e d   f o r m   o f   ( d o   J a v a S c r i p t   " e n c o d e U R I C o m p o n e n t ( w i n d o w . l o c a t i o n . h r e f ) "   i n   c u r r e n t   t a b   o f   f i r s t   w i n d o w )      l     ��  ��   vp 	set body to quoted form of (do JavaScript "encodeURIComponent((function () {var html = \"\"; if (typeof window.getSelection != \"undefined\") {var sel = window.getSelection(); if (sel.rangeCount) {var container = document.createElement(\"div\"); for (var i = 0, len = sel.rangeCount; i < len; ++i) {container.appendChild(sel.getRangeAt(i).cloneContents());} html = container.innerHTML;}} else if (typeof document.selection != \"undefined\") {if (document.selection.type == \"Text\") {html = document.selection.createRange().htmlText;}} var relToAbs = function (href) {var a = document.createElement(\"a\"); a.href = href; var abs = a.protocol + \"//\" + a.host + a.pathname + a.search + a.hash; a.remove(); return abs;}; var elementTypes = [['a', 'href'], ['img', 'src']]; var div = document.createElement('div'); div.innerHTML = html; elementTypes.map(function(elementType) {var elements = div.getElementsByTagName(elementType[0]); for (var i = 0; i < elements.length; i++) {elements[i].setAttribute(elementType[1], relToAbs(elements[i].getAttribute(elementType[1])));}}); return div.innerHTML;})());" in current tab of first window)     �  �   	 s e t   b o d y   t o   q u o t e d   f o r m   o f   ( d o   J a v a S c r i p t   " e n c o d e U R I C o m p o n e n t ( ( f u n c t i o n   ( )   { v a r   h t m l   =   \ " \ " ;   i f   ( t y p e o f   w i n d o w . g e t S e l e c t i o n   ! =   \ " u n d e f i n e d \ " )   { v a r   s e l   =   w i n d o w . g e t S e l e c t i o n ( ) ;   i f   ( s e l . r a n g e C o u n t )   { v a r   c o n t a i n e r   =   d o c u m e n t . c r e a t e E l e m e n t ( \ " d i v \ " ) ;   f o r   ( v a r   i   =   0 ,   l e n   =   s e l . r a n g e C o u n t ;   i   <   l e n ;   + + i )   { c o n t a i n e r . a p p e n d C h i l d ( s e l . g e t R a n g e A t ( i ) . c l o n e C o n t e n t s ( ) ) ; }   h t m l   =   c o n t a i n e r . i n n e r H T M L ; } }   e l s e   i f   ( t y p e o f   d o c u m e n t . s e l e c t i o n   ! =   \ " u n d e f i n e d \ " )   { i f   ( d o c u m e n t . s e l e c t i o n . t y p e   = =   \ " T e x t \ " )   { h t m l   =   d o c u m e n t . s e l e c t i o n . c r e a t e R a n g e ( ) . h t m l T e x t ; } }   v a r   r e l T o A b s   =   f u n c t i o n   ( h r e f )   { v a r   a   =   d o c u m e n t . c r e a t e E l e m e n t ( \ " a \ " ) ;   a . h r e f   =   h r e f ;   v a r   a b s   =   a . p r o t o c o l   +   \ " / / \ "   +   a . h o s t   +   a . p a t h n a m e   +   a . s e a r c h   +   a . h a s h ;   a . r e m o v e ( ) ;   r e t u r n   a b s ; } ;   v a r   e l e m e n t T y p e s   =   [ [ ' a ' ,   ' h r e f ' ] ,   [ ' i m g ' ,   ' s r c ' ] ] ;   v a r   d i v   =   d o c u m e n t . c r e a t e E l e m e n t ( ' d i v ' ) ;   d i v . i n n e r H T M L   =   h t m l ;   e l e m e n t T y p e s . m a p ( f u n c t i o n ( e l e m e n t T y p e )   { v a r   e l e m e n t s   =   d i v . g e t E l e m e n t s B y T a g N a m e ( e l e m e n t T y p e [ 0 ] ) ;   f o r   ( v a r   i   =   0 ;   i   <   e l e m e n t s . l e n g t h ;   i + + )   { e l e m e n t s [ i ] . s e t A t t r i b u t e ( e l e m e n t T y p e [ 1 ] ,   r e l T o A b s ( e l e m e n t s [ i ] . g e t A t t r i b u t e ( e l e m e n t T y p e [ 1 ] ) ) ) ; } } ) ;   r e t u r n   d i v . i n n e r H T M L ; } ) ( ) ) ; "   i n   c u r r e n t   t a b   o f   f i r s t   w i n d o w )      l     ��  ��    �  	do shell script "/usr/local/bin/emacsclient -e '(lx/capture-note \"'" & title & "'\" \"'" & link & "'\" \"'" & body & "'\")'"     �   �   	 d o   s h e l l   s c r i p t   " / u s r / l o c a l / b i n / e m a c s c l i e n t   - e   ' ( l x / c a p t u r e - n o t e   \ " ' "   &   t i t l e   &   " ' \ "   \ " ' "   &   l i n k   &   " ' \ "   \ " ' "   &   b o d y   &   " ' \ " ) ' "     !   l     �� " #��   " , & 	tell application "Emacs" to activate    # � $ $ L   	 t e l l   a p p l i c a t i o n   " E m a c s "   t o   a c t i v a t e !  % & % l     �� ' (��   ' t n 	do shell script "/usr/local/bin/terminal-notifier -title 'Note captured'  -sender org.gnu.Emacs -sound Purr"    ( � ) ) �   	 d o   s h e l l   s c r i p t   " / u s r / l o c a l / b i n / t e r m i n a l - n o t i f i e r   - t i t l e   ' N o t e   c a p t u r e d '     - s e n d e r   o r g . g n u . E m a c s   - s o u n d   P u r r " &  * + * l     �� , -��   ,  	 end tell    - � . .    e n d   t e l l +  / 0 / l     ��������  ��  ��   0  1 2 1 l   ! 3���� 3 O    ! 4 5 4 Z     6 7 8�� 6 =    9 : 9 1    ��
�� 
pnam : m     ; ; � < <  S a f a r i 7 k    � = =  > ? > O    � @ A @ k    � B B  C D C r    ) E F E n    ' G H G 1   % '��
�� 
strq H l   % I���� I I   %�� J K
�� .sfridojsnull���     ctxt J m     L L � M M D e n c o d e U R I C o m p o n e n t ( d o c u m e n t . t i t l e ) K �� N��
�� 
dcnm N n    ! O P O 1    !��
�� 
cTab P 4   �� Q
�� 
cwin Q m    ���� ��  ��  ��   F o      ���� 	0 title   D  R S R r   * < T U T n   * 8 V W V 1   6 8��
�� 
strq W l  * 6 X���� X I  * 6�� Y Z
�� .sfridojsnull���     ctxt Y m   * + [ [ � \ \ P e n c o d e U R I C o m p o n e n t ( w i n d o w . l o c a t i o n . h r e f ) Z �� ]��
�� 
dcnm ] n   , 2 ^ _ ^ 1   0 2��
�� 
cTab _ 4  , 0�� `
�� 
cwin ` m   . /���� ��  ��  ��   U o      ���� 0 link   S  a b a r   = Q c d c n   = M e f e 1   K M��
�� 
strq f l  = K g���� g I  = K�� h i
�� .sfridojsnull���     ctxt h m   = @ j j � k k( e n c o d e U R I C o m p o n e n t ( ( f u n c t i o n   ( )   { v a r   h t m l   =   " " ;   i f   ( t y p e o f   w i n d o w . g e t S e l e c t i o n   ! =   " u n d e f i n e d " )   { v a r   s e l   =   w i n d o w . g e t S e l e c t i o n ( ) ;   i f   ( s e l . r a n g e C o u n t )   { v a r   c o n t a i n e r   =   d o c u m e n t . c r e a t e E l e m e n t ( " d i v " ) ;   f o r   ( v a r   i   =   0 ,   l e n   =   s e l . r a n g e C o u n t ;   i   <   l e n ;   + + i )   { c o n t a i n e r . a p p e n d C h i l d ( s e l . g e t R a n g e A t ( i ) . c l o n e C o n t e n t s ( ) ) ; }   h t m l   =   c o n t a i n e r . i n n e r H T M L ; } }   e l s e   i f   ( t y p e o f   d o c u m e n t . s e l e c t i o n   ! =   " u n d e f i n e d " )   { i f   ( d o c u m e n t . s e l e c t i o n . t y p e   = =   " T e x t " )   { h t m l   =   d o c u m e n t . s e l e c t i o n . c r e a t e R a n g e ( ) . h t m l T e x t ; } }   v a r   r e l T o A b s   =   f u n c t i o n   ( h r e f )   { v a r   a   =   d o c u m e n t . c r e a t e E l e m e n t ( " a " ) ;   a . h r e f   =   h r e f ;   v a r   a b s   =   a . p r o t o c o l   +   " / / "   +   a . h o s t   +   a . p a t h n a m e   +   a . s e a r c h   +   a . h a s h ;   a . r e m o v e ( ) ;   r e t u r n   a b s ; } ;   v a r   e l e m e n t T y p e s   =   [ [ ' a ' ,   ' h r e f ' ] ,   [ ' i m g ' ,   ' s r c ' ] ] ;   v a r   d i v   =   d o c u m e n t . c r e a t e E l e m e n t ( ' d i v ' ) ;   d i v . i n n e r H T M L   =   h t m l ;   e l e m e n t T y p e s . m a p ( f u n c t i o n ( e l e m e n t T y p e )   { v a r   e l e m e n t s   =   d i v . g e t E l e m e n t s B y T a g N a m e ( e l e m e n t T y p e [ 0 ] ) ;   f o r   ( v a r   i   =   0 ;   i   <   e l e m e n t s . l e n g t h ;   i + + )   { e l e m e n t s [ i ] . s e t A t t r i b u t e ( e l e m e n t T y p e [ 1 ] ,   r e l T o A b s ( e l e m e n t s [ i ] . g e t A t t r i b u t e ( e l e m e n t T y p e [ 1 ] ) ) ) ; } } ) ;   r e t u r n   d i v . i n n e r H T M L ; } ) ( ) ) ; i �� l��
�� 
dcnm l n   A G m n m 1   E G��
�� 
cTab n 4  A E�� o
�� 
cwin o m   C D���� ��  ��  ��   d o      ���� 0 body   b  p q p l  R R��������  ��  ��   q  r s r I  R o�� t��
�� .sysoexecTEXT���     TEXT t b   R k u v u b   R g w x w b   R c y z y b   R _ { | { b   R [ } ~ } b   R W  �  m   R U � � � � � e x p o r t   p r e f i x = / u s r / l o c a l ;   i f   [   - e   / o p t / h o m e b r e w   ] ;   t h e n   p r e f i x = / o p t / h o m e b r e w ;   f i ;   $ p r e f i x / b i n / e m a c s c l i e n t   - e   ' ( l x / c a p t u r e - n o t e   " ' � o   U V���� 	0 title   ~ m   W Z � � � � � 
 ' "   " ' | o   [ ^���� 0 link   z m   _ b � � � � � 
 ' "   " ' x o   c f���� 0 body   v m   g j � � � � �  ' " ) '��   s  � � � O  p | � � � I  v {������
�� .miscactvnull��� ��� null��  ��   � m   p s � �|                                                                                  EMAx  alis      Macintosh HD               ��	BD ����	Emacs.app                                                      �������        ����  
 cu             Applications  /:Applications:Emacs.app/    	 E m a c s . a p p    M a c i n t o s h   H D  Applications/Emacs.app  / ��   �  � � � I  } ��� ���
�� .sysoexecTEXT���     TEXT � m   } � � � � � �R e x p o r t   p r e f i x = / u s r / l o c a l ;   i f   [   - e   / o p t / h o m e b r e w   ] ;   t h e n   p r e f i x = / o p t / h o m e b r e w ;   f i ;   $ p r e f i x / b i n / t e r m i n a l - n o t i f i e r   - t i t l e   ' N o t e   c a p t u r e d '     - s e n d e r   o r g . g n u . E m a c s   - s o u n d   P u r r��   �  ��� � l  � ���������  ��  ��  ��   A m     � ��                                                                                  sfri  alis    p  Preboot                    ���BD ����
Safari.app                                                     �������%        ����  
 cu             Applications  F/:System:Volumes:Preboot:Cryptexes:App:System:Applications:Safari.app/   
 S a f a r i . a p p    P r e b o o t  -/Cryptexes/App/System/Applications/Safari.app   /System/Volumes/Preboot ��   ?  ��� � l  � ���������  ��  ��  ��   8  � � � =  � � � � � 1   � ���
�� 
pnam � m   � � � � � � �  M i c r o s o f t   E d g e �  ��� � O   � � � � k   � � �  � � � r   � � � � � n   � � � � � 1   � ���
�� 
strq � l  � � ����� � I  � ��� � �
�� .CrSuExJanull���     obj  � n   � � � � � 1   � ���
�� 
acTa � 4  � ��� �
�� 
cwin � m   � �����  � �� ���
�� 
JvSc � m   � � � � � � � D e n c o d e U R I C o m p o n e n t ( d o c u m e n t . t i t l e )��  ��  ��   � o      ���� 
0 xtitle   �  � � � r   � � � � � n   � � � � � 1   � ���
�� 
strq � l  � � ����� � I  � ��� � �
�� .CrSuExJanull���     obj  � n   � � � � � 1   � ���
�� 
acTa � 4  � ��� �
�� 
cwin � m   � �����  � �� ���
�� 
JvSc � m   � � � � � � � P e n c o d e U R I C o m p o n e n t ( w i n d o w . l o c a t i o n . h r e f )��  ��  ��   � o      ���� 	0 xlink   �  � � � r   � � � � � n   � � � � � 1   � ���
�� 
strq � l  � � ����� � I  � ��� � �
�� .CrSuExJanull���     obj  � n   � � � � � 1   � ���
�� 
acTa � 4  � ��� �
�� 
cwin � m   � �����  � �� ���
�� 
JvSc � m   � � � � � � �( e n c o d e U R I C o m p o n e n t ( ( f u n c t i o n   ( )   { v a r   h t m l   =   " " ;   i f   ( t y p e o f   w i n d o w . g e t S e l e c t i o n   ! =   " u n d e f i n e d " )   { v a r   s e l   =   w i n d o w . g e t S e l e c t i o n ( ) ;   i f   ( s e l . r a n g e C o u n t )   { v a r   c o n t a i n e r   =   d o c u m e n t . c r e a t e E l e m e n t ( " d i v " ) ;   f o r   ( v a r   i   =   0 ,   l e n   =   s e l . r a n g e C o u n t ;   i   <   l e n ;   + + i )   { c o n t a i n e r . a p p e n d C h i l d ( s e l . g e t R a n g e A t ( i ) . c l o n e C o n t e n t s ( ) ) ; }   h t m l   =   c o n t a i n e r . i n n e r H T M L ; } }   e l s e   i f   ( t y p e o f   d o c u m e n t . s e l e c t i o n   ! =   " u n d e f i n e d " )   { i f   ( d o c u m e n t . s e l e c t i o n . t y p e   = =   " T e x t " )   { h t m l   =   d o c u m e n t . s e l e c t i o n . c r e a t e R a n g e ( ) . h t m l T e x t ; } }   v a r   r e l T o A b s   =   f u n c t i o n   ( h r e f )   { v a r   a   =   d o c u m e n t . c r e a t e E l e m e n t ( " a " ) ;   a . h r e f   =   h r e f ;   v a r   a b s   =   a . p r o t o c o l   +   " / / "   +   a . h o s t   +   a . p a t h n a m e   +   a . s e a r c h   +   a . h a s h ;   a . r e m o v e ( ) ;   r e t u r n   a b s ; } ;   v a r   e l e m e n t T y p e s   =   [ [ ' a ' ,   ' h r e f ' ] ,   [ ' i m g ' ,   ' s r c ' ] ] ;   v a r   d i v   =   d o c u m e n t . c r e a t e E l e m e n t ( ' d i v ' ) ;   d i v . i n n e r H T M L   =   h t m l ;   e l e m e n t T y p e s . m a p ( f u n c t i o n ( e l e m e n t T y p e )   { v a r   e l e m e n t s   =   d i v . g e t E l e m e n t s B y T a g N a m e ( e l e m e n t T y p e [ 0 ] ) ;   f o r   ( v a r   i   =   0 ;   i   <   e l e m e n t s . l e n g t h ;   i + + )   { e l e m e n t s [ i ] . s e t A t t r i b u t e ( e l e m e n t T y p e [ 1 ] ,   r e l T o A b s ( e l e m e n t s [ i ] . g e t A t t r i b u t e ( e l e m e n t T y p e [ 1 ] ) ) ) ; } } ) ;   r e t u r n   d i v . i n n e r H T M L ; } ) ( ) ) ;��  ��  ��   � o      ���� 	0 xbody   �  � � � l  � ���������  ��  ��   �  � � � I  ��� ���
�� .sysoexecTEXT���     TEXT � b   � � � � b   � � � � � b   � � � � � b   � � � � � b   � � � � � b   � � � � � m   � � � � � � � e x p o r t   p r e f i x = / u s r / l o c a l ;   i f   [   - e   / o p t / h o m e b r e w   ] ;   t h e n   p r e f i x = / o p t / h o m e b r e w ;   f i ;   $ p r e f i x / b i n / e m a c s c l i e n t   - e   ' ( l x / c a p t u r e - n o t e   " ' � o   � ����� 
0 xtitle   � m   � � � � � � � 
 ' "   " ' � o   � ����� 	0 xlink   � m   � � � � � � � 
 ' "   " ' � o   � ����� 	0 xbody   � m   � � � � � �  ' " ) '��   �  � � � O  � � � I ������
�� .miscactvnull��� ��� null��  ��   � m  
 � �|                                                                                  EMAx  alis      Macintosh HD               ��	BD ����	Emacs.app                                                      �������        ����  
 cu             Applications  /:Applications:Emacs.app/    	 E m a c s . a p p    M a c i n t o s h   H D  Applications/Emacs.app  / ��   �  ��� � I �� ���
�� .sysoexecTEXT���     TEXT � m   � � � � �R e x p o r t   p r e f i x = / u s r / l o c a l ;   i f   [   - e   / o p t / h o m e b r e w   ] ;   t h e n   p r e f i x = / o p t / h o m e b r e w ;   f i ;   $ p r e f i x / b i n / t e r m i n a l - n o t i f i e r   - t i t l e   ' N o t e   c a p t u r e d '     - s e n d e r   o r g . g n u . E m a c s   - s o u n d   P u r r��  ��   � m   � � � ��                                                                                  EDGE  alis    B  Macintosh HD               ��	BD ����Microsoft Edge.app                                             ������d�        ����  
 cu             Applications  "/:Applications:Microsoft Edge.app/  &  M i c r o s o f t   E d g e . a p p    M a c i n t o s h   H D  Applications/Microsoft Edge.app   / ��  ��  ��   5 4     
�� �
�� 
capp � l   	 ����� � I   	�� � �
�� .earsffdralis        afdr � m    ��
�� appfegfp � �� ���
�� 
rtyp � m    ��
�� 
ctxt��  ��  ��  ��  ��   2  ��� � l     ��������  ��  ��  ��       � � ��   � �~
�~ .aevtoappnull  �   � **** � �} ��|�{ � ��z
�} .aevtoappnull  �   � **** � k    ! � �  1�y�y  �|  �{   �   � +�x�w�v�u�t�s ; � L�r�q�p�o�n�m [�l j�k � � � ��j ��i � � ��h�g ��f�e ��d ��c � � � � �
�x 
capp
�w appfegfp
�v 
rtyp
�u 
ctxt
�t .earsffdralis        afdr
�s 
pnam
�r 
dcnm
�q 
cwin
�p 
cTab
�o .sfridojsnull���     ctxt
�n 
strq�m 	0 title  �l 0 link  �k 0 body  
�j .sysoexecTEXT���     TEXT
�i .miscactvnull��� ��� null
�h 
acTa
�g 
JvSc
�f .CrSuExJanull���     obj �e 
0 xtitle  �d 	0 xlink  �c 	0 xbody  �z"*����l /*�,�  y� o��*�k/�,l �,E�O��*�k/�,l �,E` Oa �*�k/�,l �,E` Oa �%a %_ %a %_ %a %j Oa  *j UOa j OPUOPY �*�,a   �a  �*�k/a ,a a l  �,E` !O*�k/a ,a a "l  �,E` #O*�k/a ,a a $l  �,E` %Oa &_ !%a '%_ #%a (%_ %%a )%j Oa  *j UOa *j UY hU ascr  ��ޭ