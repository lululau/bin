FasdUAS 1.101.10   ��   ��    k             l     ��  ��       tell application "Safari"     � 	 	 4   t e l l   a p p l i c a t i o n   " S a f a r i "   
  
 l     ��  ��   .( 	set org_url to do JavaScript "('org-protocol://capture-html?template=w&url=' + encodeURIComponent(location.href) + '&title=' + encodeURIComponent(document.title || \"[untitled page]\") + '&body=' + encodeURIComponent(function () {var html = \"\"; if (typeof window.getSelection != \"undefined\") {var sel = window.getSelection(); if (sel.rangeCount) {var container = document.createElement(\"div\"); for (var i = 0, len = sel.rangeCount; i < len; ++i) {container.appendChild(sel.getRangeAt(i).cloneContents());} html = container.innerHTML;}} else if (typeof document.selection != \"undefined\") {if (document.selection.type == \"Text\") {html = document.selection.createRange().htmlText;}} var relToAbs = function (href) {var a = document.createElement(\"a\"); a.href = href; var abs = a.protocol + \"//\" + a.host + a.pathname + a.search + a.hash; a.remove(); return abs;}; var elementTypes = [['a', 'href'], ['img', 'src']]; var div = document.createElement('div'); div.innerHTML = html; elementTypes.map(function(elementType) {var elements = div.getElementsByTagName(elementType[0]); for (var i = 0; i < elements.length; i++) {elements[i].setAttribute(elementType[1], relToAbs(elements[i].getAttribute(elementType[1])));}}); return div.innerHTML;}())).replace(/'/g, \"'\\\"'\\\"'\");" in current tab of first window     �  
P   	 s e t   o r g _ u r l   t o   d o   J a v a S c r i p t   " ( ' o r g - p r o t o c o l : / / c a p t u r e - h t m l ? t e m p l a t e = w & u r l = '   +   e n c o d e U R I C o m p o n e n t ( l o c a t i o n . h r e f )   +   ' & t i t l e = '   +   e n c o d e U R I C o m p o n e n t ( d o c u m e n t . t i t l e   | |   \ " [ u n t i t l e d   p a g e ] \ " )   +   ' & b o d y = '   +   e n c o d e U R I C o m p o n e n t ( f u n c t i o n   ( )   { v a r   h t m l   =   \ " \ " ;   i f   ( t y p e o f   w i n d o w . g e t S e l e c t i o n   ! =   \ " u n d e f i n e d \ " )   { v a r   s e l   =   w i n d o w . g e t S e l e c t i o n ( ) ;   i f   ( s e l . r a n g e C o u n t )   { v a r   c o n t a i n e r   =   d o c u m e n t . c r e a t e E l e m e n t ( \ " d i v \ " ) ;   f o r   ( v a r   i   =   0 ,   l e n   =   s e l . r a n g e C o u n t ;   i   <   l e n ;   + + i )   { c o n t a i n e r . a p p e n d C h i l d ( s e l . g e t R a n g e A t ( i ) . c l o n e C o n t e n t s ( ) ) ; }   h t m l   =   c o n t a i n e r . i n n e r H T M L ; } }   e l s e   i f   ( t y p e o f   d o c u m e n t . s e l e c t i o n   ! =   \ " u n d e f i n e d \ " )   { i f   ( d o c u m e n t . s e l e c t i o n . t y p e   = =   \ " T e x t \ " )   { h t m l   =   d o c u m e n t . s e l e c t i o n . c r e a t e R a n g e ( ) . h t m l T e x t ; } }   v a r   r e l T o A b s   =   f u n c t i o n   ( h r e f )   { v a r   a   =   d o c u m e n t . c r e a t e E l e m e n t ( \ " a \ " ) ;   a . h r e f   =   h r e f ;   v a r   a b s   =   a . p r o t o c o l   +   \ " / / \ "   +   a . h o s t   +   a . p a t h n a m e   +   a . s e a r c h   +   a . h a s h ;   a . r e m o v e ( ) ;   r e t u r n   a b s ; } ;   v a r   e l e m e n t T y p e s   =   [ [ ' a ' ,   ' h r e f ' ] ,   [ ' i m g ' ,   ' s r c ' ] ] ;   v a r   d i v   =   d o c u m e n t . c r e a t e E l e m e n t ( ' d i v ' ) ;   d i v . i n n e r H T M L   =   h t m l ;   e l e m e n t T y p e s . m a p ( f u n c t i o n ( e l e m e n t T y p e )   { v a r   e l e m e n t s   =   d i v . g e t E l e m e n t s B y T a g N a m e ( e l e m e n t T y p e [ 0 ] ) ;   f o r   ( v a r   i   =   0 ;   i   <   e l e m e n t s . l e n g t h ;   i + + )   { e l e m e n t s [ i ] . s e t A t t r i b u t e ( e l e m e n t T y p e [ 1 ] ,   r e l T o A b s ( e l e m e n t s [ i ] . g e t A t t r i b u t e ( e l e m e n t T y p e [ 1 ] ) ) ) ; } } ) ;   r e t u r n   d i v . i n n e r H T M L ; } ( ) ) ) . r e p l a c e ( / ' / g ,   \ " ' \ \ \ " ' \ \ \ " ' \ " ) ; "   i n   c u r r e n t   t a b   o f   f i r s t   w i n d o w      l     ��  ��    0 * 	do shell script "open '" & org_url & "'"     �   T   	 d o   s h e l l   s c r i p t   " o p e n   ' "   &   o r g _ u r l   &   " ' "      l     ��  ��    t n 	do shell script "/usr/local/bin/terminal-notifier -title 'Page captured'  -sender org.gnu.Emacs -sound Purr"     �   �   	 d o   s h e l l   s c r i p t   " / u s r / l o c a l / b i n / t e r m i n a l - n o t i f i e r   - t i t l e   ' P a g e   c a p t u r e d '     - s e n d e r   o r g . g n u . E m a c s   - s o u n d   P u r r "      l     ��  ��     	 end tell     �      e n d   t e l l      l     ��������  ��  ��       !   l     ��������  ��  ��   !  " # " l     �� $ %��   $  tell application "Safari"    % � & & 2 t e l l   a p p l i c a t i o n   " S a f a r i " #  ' ( ' l     �� ) *��   ) v p	set title to quoted form of (do JavaScript "encodeURIComponent(document.title)" in current tab of first window)    * � + + � 	 s e t   t i t l e   t o   q u o t e d   f o r m   o f   ( d o   J a v a S c r i p t   " e n c o d e U R I C o m p o n e n t ( d o c u m e n t . t i t l e ) "   i n   c u r r e n t   t a b   o f   f i r s t   w i n d o w ) (  , - , l     �� . /��   . { u	set link to quoted form of (do JavaScript "encodeURIComponent(window.location.href)" in current tab of first window)    / � 0 0 � 	 s e t   l i n k   t o   q u o t e d   f o r m   o f   ( d o   J a v a S c r i p t   " e n c o d e U R I C o m p o n e n t ( w i n d o w . l o c a t i o n . h r e f ) "   i n   c u r r e n t   t a b   o f   f i r s t   w i n d o w ) -  1 2 1 l     �� 3 4��   3uo	set body to quoted form of (do JavaScript "encodeURIComponent((function () {var html = \"\"; if (typeof window.getSelection != \"undefined\") {var sel = window.getSelection(); if (sel.rangeCount) {var container = document.createElement(\"div\"); for (var i = 0, len = sel.rangeCount; i < len; ++i) {container.appendChild(sel.getRangeAt(i).cloneContents());} html = container.innerHTML;}} else if (typeof document.selection != \"undefined\") {if (document.selection.type == \"Text\") {html = document.selection.createRange().htmlText;}} var relToAbs = function (href) {var a = document.createElement(\"a\"); a.href = href; var abs = a.protocol + \"//\" + a.host + a.pathname + a.search + a.hash; a.remove(); return abs;}; var elementTypes = [['a', 'href'], ['img', 'src']]; var div = document.createElement('div'); div.innerHTML = html; elementTypes.map(function(elementType) {var elements = div.getElementsByTagName(elementType[0]); for (var i = 0; i < elements.length; i++) {elements[i].setAttribute(elementType[1], relToAbs(elements[i].getAttribute(elementType[1])));}}); return div.innerHTML;})());" in current tab of first window)    4 � 5 5� 	 s e t   b o d y   t o   q u o t e d   f o r m   o f   ( d o   J a v a S c r i p t   " e n c o d e U R I C o m p o n e n t ( ( f u n c t i o n   ( )   { v a r   h t m l   =   \ " \ " ;   i f   ( t y p e o f   w i n d o w . g e t S e l e c t i o n   ! =   \ " u n d e f i n e d \ " )   { v a r   s e l   =   w i n d o w . g e t S e l e c t i o n ( ) ;   i f   ( s e l . r a n g e C o u n t )   { v a r   c o n t a i n e r   =   d o c u m e n t . c r e a t e E l e m e n t ( \ " d i v \ " ) ;   f o r   ( v a r   i   =   0 ,   l e n   =   s e l . r a n g e C o u n t ;   i   <   l e n ;   + + i )   { c o n t a i n e r . a p p e n d C h i l d ( s e l . g e t R a n g e A t ( i ) . c l o n e C o n t e n t s ( ) ) ; }   h t m l   =   c o n t a i n e r . i n n e r H T M L ; } }   e l s e   i f   ( t y p e o f   d o c u m e n t . s e l e c t i o n   ! =   \ " u n d e f i n e d \ " )   { i f   ( d o c u m e n t . s e l e c t i o n . t y p e   = =   \ " T e x t \ " )   { h t m l   =   d o c u m e n t . s e l e c t i o n . c r e a t e R a n g e ( ) . h t m l T e x t ; } }   v a r   r e l T o A b s   =   f u n c t i o n   ( h r e f )   { v a r   a   =   d o c u m e n t . c r e a t e E l e m e n t ( \ " a \ " ) ;   a . h r e f   =   h r e f ;   v a r   a b s   =   a . p r o t o c o l   +   \ " / / \ "   +   a . h o s t   +   a . p a t h n a m e   +   a . s e a r c h   +   a . h a s h ;   a . r e m o v e ( ) ;   r e t u r n   a b s ; } ;   v a r   e l e m e n t T y p e s   =   [ [ ' a ' ,   ' h r e f ' ] ,   [ ' i m g ' ,   ' s r c ' ] ] ;   v a r   d i v   =   d o c u m e n t . c r e a t e E l e m e n t ( ' d i v ' ) ;   d i v . i n n e r H T M L   =   h t m l ;   e l e m e n t T y p e s . m a p ( f u n c t i o n ( e l e m e n t T y p e )   { v a r   e l e m e n t s   =   d i v . g e t E l e m e n t s B y T a g N a m e ( e l e m e n t T y p e [ 0 ] ) ;   f o r   ( v a r   i   =   0 ;   i   <   e l e m e n t s . l e n g t h ;   i + + )   { e l e m e n t s [ i ] . s e t A t t r i b u t e ( e l e m e n t T y p e [ 1 ] ,   r e l T o A b s ( e l e m e n t s [ i ] . g e t A t t r i b u t e ( e l e m e n t T y p e [ 1 ] ) ) ) ; } } ) ;   r e t u r n   d i v . i n n e r H T M L ; } ) ( ) ) ; "   i n   c u r r e n t   t a b   o f   f i r s t   w i n d o w ) 2  6 7 6 l     �� 8 9��   8 + %	tell application "Emacs" to activate    9 � : : J 	 t e l l   a p p l i c a t i o n   " E m a c s "   t o   a c t i v a t e 7  ; < ; l     �� = >��   = � �	do shell script "/usr/local/bin/emacsclient -e '(org-protocol-capture-html--with-pandoc-patch \"'" & "w" & "'\" \"'" & title & "'\" \"'" & link & "'\" \"'" & body & "'\")'"    > � ? ?Z 	 d o   s h e l l   s c r i p t   " / u s r / l o c a l / b i n / e m a c s c l i e n t   - e   ' ( o r g - p r o t o c o l - c a p t u r e - h t m l - - w i t h - p a n d o c - p a t c h   \ " ' "   &   " w "   &   " ' \ "   \ " ' "   &   t i t l e   &   " ' \ "   \ " ' "   &   l i n k   &   " ' \ "   \ " ' "   &   b o d y   &   " ' \ " ) ' " <  @ A @ l     �� B C��   B s m	do shell script "/usr/local/bin/terminal-notifier -title 'Page captured'  -sender org.gnu.Emacs -sound Purr"    C � D D � 	 d o   s h e l l   s c r i p t   " / u s r / l o c a l / b i n / t e r m i n a l - n o t i f i e r   - t i t l e   ' P a g e   c a p t u r e d '     - s e n d e r   o r g . g n u . E m a c s   - s o u n d   P u r r " A  E F E l     �� G H��   G  end tell    H � I I  e n d   t e l l F  J K J l     ��������  ��  ��   K  L M L l     ��������  ��  ��   M  N O N l   / P���� P O    / Q R Q Z   . S T U�� S =    V W V 1    ��
�� 
pnam W m     X X � Y Y  S a f a r i T k    � Z Z  [ \ [ O    � ] ^ ] k    � _ _  ` a ` r    ) b c b n    ' d e d 1   % '��
�� 
strq e l   % f���� f I   %�� g h
�� .sfridojsnull���     ctxt g m     i i � j j D e n c o d e U R I C o m p o n e n t ( d o c u m e n t . t i t l e ) h �� k��
�� 
dcnm k n    ! l m l 1    !��
�� 
cTab m 4   �� n
�� 
cwin n m    ���� ��  ��  ��   c o      ���� 	0 title   a  o p o r   * < q r q n   * 8 s t s 1   6 8��
�� 
strq t l  * 6 u���� u I  * 6�� v w
�� .sfridojsnull���     ctxt v m   * + x x � y y P e n c o d e U R I C o m p o n e n t ( w i n d o w . l o c a t i o n . h r e f ) w �� z��
�� 
dcnm z n   , 2 { | { 1   0 2��
�� 
cTab | 4  , 0�� }
�� 
cwin } m   . /���� ��  ��  ��   r o      ���� 0 link   p  ~  ~ r   = Q � � � n   = M � � � 1   K M��
�� 
strq � l  = K ����� � I  = K�� � �
�� .sfridojsnull���     ctxt � m   = @ � � � � �( e n c o d e U R I C o m p o n e n t ( ( f u n c t i o n   ( )   { v a r   h t m l   =   " " ;   i f   ( t y p e o f   w i n d o w . g e t S e l e c t i o n   ! =   " u n d e f i n e d " )   { v a r   s e l   =   w i n d o w . g e t S e l e c t i o n ( ) ;   i f   ( s e l . r a n g e C o u n t )   { v a r   c o n t a i n e r   =   d o c u m e n t . c r e a t e E l e m e n t ( " d i v " ) ;   f o r   ( v a r   i   =   0 ,   l e n   =   s e l . r a n g e C o u n t ;   i   <   l e n ;   + + i )   { c o n t a i n e r . a p p e n d C h i l d ( s e l . g e t R a n g e A t ( i ) . c l o n e C o n t e n t s ( ) ) ; }   h t m l   =   c o n t a i n e r . i n n e r H T M L ; } }   e l s e   i f   ( t y p e o f   d o c u m e n t . s e l e c t i o n   ! =   " u n d e f i n e d " )   { i f   ( d o c u m e n t . s e l e c t i o n . t y p e   = =   " T e x t " )   { h t m l   =   d o c u m e n t . s e l e c t i o n . c r e a t e R a n g e ( ) . h t m l T e x t ; } }   v a r   r e l T o A b s   =   f u n c t i o n   ( h r e f )   { v a r   a   =   d o c u m e n t . c r e a t e E l e m e n t ( " a " ) ;   a . h r e f   =   h r e f ;   v a r   a b s   =   a . p r o t o c o l   +   " / / "   +   a . h o s t   +   a . p a t h n a m e   +   a . s e a r c h   +   a . h a s h ;   a . r e m o v e ( ) ;   r e t u r n   a b s ; } ;   v a r   e l e m e n t T y p e s   =   [ [ ' a ' ,   ' h r e f ' ] ,   [ ' i m g ' ,   ' s r c ' ] ] ;   v a r   d i v   =   d o c u m e n t . c r e a t e E l e m e n t ( ' d i v ' ) ;   d i v . i n n e r H T M L   =   h t m l ;   e l e m e n t T y p e s . m a p ( f u n c t i o n ( e l e m e n t T y p e )   { v a r   e l e m e n t s   =   d i v . g e t E l e m e n t s B y T a g N a m e ( e l e m e n t T y p e [ 0 ] ) ;   f o r   ( v a r   i   =   0 ;   i   <   e l e m e n t s . l e n g t h ;   i + + )   { e l e m e n t s [ i ] . s e t A t t r i b u t e ( e l e m e n t T y p e [ 1 ] ,   r e l T o A b s ( e l e m e n t s [ i ] . g e t A t t r i b u t e ( e l e m e n t T y p e [ 1 ] ) ) ) ; } } ) ;   r e t u r n   d i v . i n n e r H T M L ; } ) ( ) ) ; � �� ���
�� 
dcnm � n   A G � � � 1   E G��
�� 
cTab � 4  A E�� �
�� 
cwin � m   C D���� ��  ��  ��   � o      ���� 0 body     � � � O  R ^ � � � I  X ]������
�� .miscactvnull��� ��� null��  ��   � m   R U � �|                                                                                  EMAx  alis      Macintosh HD               ��	BD ����	Emacs.app                                                      �������        ����  
 cu             Applications  /:Applications:Emacs.app/    	 E m a c s . a p p    M a c i n t o s h   H D  Applications/Emacs.app  / ��   �  � � � I  _ ��� ���
�� .sysoexecTEXT���     TEXT � b   _ � � � � b   _ | � � � b   _ x � � � b   _ t � � � b   _ p � � � b   _ l � � � b   _ j � � � b   _ f � � � m   _ b � � � � �< e x p o r t   p r e f i x = / u s r / l o c a l ;   i f   [   - e   / o p t / h o m e b r e w   ] ;   t h e n   p r e f i x = / o p t / h o m e b r e w ;   f i ;   $ p r e f i x / b i n / e m a c s c l i e n t   - e   ' ( o r g - p r o t o c o l - c a p t u r e - h t m l - - w i t h - p a n d o c - p a t c h   " ' � m   b e � � � � �  w � m   f i � � � � � 
 ' "   " ' � o   j k���� 	0 title   � m   l o � � � � � 
 ' "   " ' � o   p s���� 0 link   � m   t w � � � � � 
 ' "   " ' � o   x {���� 0 body   � m   |  � � � � �  ' " ) '��   �  ��� � I  � ��� ���
�� .sysoexecTEXT���     TEXT � m   � � � � � � �R e x p o r t   p r e f i x = / u s r / l o c a l ;   i f   [   - e   / o p t / h o m e b r e w   ] ;   t h e n   p r e f i x = / o p t / h o m e b r e w ;   f i ;   $ p r e f i x / b i n / t e r m i n a l - n o t i f i e r   - t i t l e   ' P a g e   c a p t u r e d '     - s e n d e r   o r g . g n u . E m a c s   - s o u n d   P u r r��  ��   ^ m     � ��                                                                                  sfri  alis    p  Preboot                    ���BD ����
Safari.app                                                     �������%        ����  
 cu             Applications  F/:System:Volumes:Preboot:Cryptexes:App:System:Applications:Safari.app/   
 S a f a r i . a p p    P r e b o o t  -/Cryptexes/App/System/Applications/Safari.app   /System/Volumes/Preboot ��   \  ��� � l  � ���������  ��  ��  ��   U  � � � =  � � � � � 1   � ���
�� 
pnam � m   � � � � � � �  M i c r o s o f t   E d g e �  ��� � O   �* � � � k   �) � �  � � � r   � � � � � n   � � � � � 1   � ���
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
JvSc � m   � � � � � � �( e n c o d e U R I C o m p o n e n t ( ( f u n c t i o n   ( )   { v a r   h t m l   =   " " ;   i f   ( t y p e o f   w i n d o w . g e t S e l e c t i o n   ! =   " u n d e f i n e d " )   { v a r   s e l   =   w i n d o w . g e t S e l e c t i o n ( ) ;   i f   ( s e l . r a n g e C o u n t )   { v a r   c o n t a i n e r   =   d o c u m e n t . c r e a t e E l e m e n t ( " d i v " ) ;   f o r   ( v a r   i   =   0 ,   l e n   =   s e l . r a n g e C o u n t ;   i   <   l e n ;   + + i )   { c o n t a i n e r . a p p e n d C h i l d ( s e l . g e t R a n g e A t ( i ) . c l o n e C o n t e n t s ( ) ) ; }   h t m l   =   c o n t a i n e r . i n n e r H T M L ; } }   e l s e   i f   ( t y p e o f   d o c u m e n t . s e l e c t i o n   ! =   " u n d e f i n e d " )   { i f   ( d o c u m e n t . s e l e c t i o n . t y p e   = =   " T e x t " )   { h t m l   =   d o c u m e n t . s e l e c t i o n . c r e a t e R a n g e ( ) . h t m l T e x t ; } }   v a r   r e l T o A b s   =   f u n c t i o n   ( h r e f )   { v a r   a   =   d o c u m e n t . c r e a t e E l e m e n t ( " a " ) ;   a . h r e f   =   h r e f ;   v a r   a b s   =   a . p r o t o c o l   +   " / / "   +   a . h o s t   +   a . p a t h n a m e   +   a . s e a r c h   +   a . h a s h ;   a . r e m o v e ( ) ;   r e t u r n   a b s ; } ;   v a r   e l e m e n t T y p e s   =   [ [ ' a ' ,   ' h r e f ' ] ,   [ ' i m g ' ,   ' s r c ' ] ] ;   v a r   d i v   =   d o c u m e n t . c r e a t e E l e m e n t ( ' d i v ' ) ;   d i v . i n n e r H T M L   =   h t m l ;   e l e m e n t T y p e s . m a p ( f u n c t i o n ( e l e m e n t T y p e )   { v a r   e l e m e n t s   =   d i v . g e t E l e m e n t s B y T a g N a m e ( e l e m e n t T y p e [ 0 ] ) ;   f o r   ( v a r   i   =   0 ;   i   <   e l e m e n t s . l e n g t h ;   i + + )   { e l e m e n t s [ i ] . s e t A t t r i b u t e ( e l e m e n t T y p e [ 1 ] ,   r e l T o A b s ( e l e m e n t s [ i ] . g e t A t t r i b u t e ( e l e m e n t T y p e [ 1 ] ) ) ) ; } } ) ;   r e t u r n   d i v . i n n e r H T M L ; } ) ( ) ) ;��  ��  ��   � o      ���� 	0 xbody   �  � � � l  � ���������  ��  ��   �  � � � O  � � � � � I  � �������
�� .miscactvnull��� ��� null��  ��   � m   � � � �|                                                                                  EMAx  alis      Macintosh HD               ��	BD ����	Emacs.app                                                      �������        ����  
 cu             Applications  /:Applications:Emacs.app/    	 E m a c s . a p p    M a c i n t o s h   H D  Applications/Emacs.app  / ��   �  � � � l  � ���������  ��  ��   �  � � � I  �!�� ���
�� .sysoexecTEXT���     TEXT � b   � � � � b   � � � � b   � � � � b   �   b   � b   �	 b   � b   �	 m   � �

 �< e x p o r t   p r e f i x = / u s r / l o c a l ;   i f   [   - e   / o p t / h o m e b r e w   ] ;   t h e n   p r e f i x = / o p t / h o m e b r e w ;   f i ;   $ p r e f i x / b i n / e m a c s c l i e n t   - e   ' ( o r g - p r o t o c o l - c a p t u r e - h t m l - - w i t h - p a n d o c - p a t c h   " '	 m   �  �  w m   � 
 ' "   " ' o  ���� 
0 xtitle   m  	 � 
 ' "   " ' o  ���� 	0 xlink   � m   � 
 ' "   " ' � o  ���� 	0 xbody   � m   �  ' " ) '��   � �� I ")����
�� .sysoexecTEXT���     TEXT m  "% �R e x p o r t   p r e f i x = / u s r / l o c a l ;   i f   [   - e   / o p t / h o m e b r e w   ] ;   t h e n   p r e f i x = / o p t / h o m e b r e w ;   f i ;   $ p r e f i x / b i n / t e r m i n a l - n o t i f i e r   - t i t l e   ' P a g e   c a p t u r e d '     - s e n d e r   o r g . g n u . E m a c s   - s o u n d   P u r r��  ��   � m   � ��                                                                                  EDGE  alis    B  Macintosh HD               ��	BD ����Microsoft Edge.app                                             ������d�        ����  
 cu             Applications  "/:Applications:Microsoft Edge.app/  &  M i c r o s o f t   E d g e . a p p    M a c i n t o s h   H D  Applications/Microsoft Edge.app   / ��  ��  ��   R 4     
��
�� 
capp l   	���� I   	��
�� .earsffdralis        afdr m    �
� appfegfp �~�}
�~ 
rtyp m    �|
�| 
ctxt�}  ��  ��  ��  ��   O  �{  l     �z�y�x�z  �y  �x  �{       �w!"�w  ! �v
�v .aevtoappnull  �   � ****" �u#�t�s$%�r
�u .aevtoappnull  �   � ****# k    /&&  N�q�q  �t  �s  $  % /�p�o�n�m�l�k X � i�j�i�h�g�f�e x�d ��c ��b � � � � � ��a � ��`�_ ��^�] ��\ ��[

�p 
capp
�o appfegfp
�n 
rtyp
�m 
ctxt
�l .earsffdralis        afdr
�k 
pnam
�j 
dcnm
�i 
cwin
�h 
cTab
�g .sfridojsnull���     ctxt
�f 
strq�e 	0 title  �d 0 link  �c 0 body  
�b .miscactvnull��� ��� null
�a .sysoexecTEXT���     TEXT
�` 
acTa
�_ 
JvSc
�^ .CrSuExJanull���     obj �] 
0 xtitle  �\ 	0 xlink  �[ 	0 xbody  �r0*����l /#*�,�  � u��*�k/�,l �,E�O��*�k/�,l �,E` Oa �*�k/�,l �,E` Oa  *j UOa a %a %�%a %_ %a %_ %a %j Oa j UOPY �*�,a   �a  �*�k/a ,a  a !l "�,E` #O*�k/a ,a  a $l "�,E` %O*�k/a ,a  a &l "�,E` 'Oa  *j UOa (a )%a *%_ #%a +%_ %%a ,%_ '%a -%j Oa .j UY hU ascr  ��ޭ