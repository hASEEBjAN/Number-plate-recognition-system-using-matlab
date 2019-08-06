%CREATE TEMPLATES 
%Alphabets
A=imread('alpha/A.bmp');B=imread('alpha/B.bmp');C=imread('alpha/C.bmp');
D=imread('alpha/D.bmp'); D=imbinarize(D); 
D1=imread('alpha/D_1.bmp'); D1=rgb2gray(D1); D1=imbinarize(D1); D1=imcrop(D1,[87,30,24,42]); D1=imresize(D1,[42 24]); 
E=imread('alpha/E.bmp');F=imread('alpha/F.bmp');
G=imread('alpha/G.bmp');H=imread('alpha/H.bmp');I=imread('alpha/I.bmp');
J=imread('alpha/J.bmp');K=imread('alpha/K.bmp');L=imread('alpha/L.bmp');
M=imread('alpha/M.bmp'); M=imbinarize(M);
M1=imread('alpha/M_1.bmp'); M1=rgb2gray(M1); M1=imbinarize(M1);M1=imcrop(M1,[87,30,24,42]);  M1=imresize(M1,[42 24]);
N=imread('alpha/N.bmp');O=imread('alpha/O.bmp');
P=imread('alpha/P.bmp');Q=imread('alpha/Q.bmp');R=imread('alpha/R.bmp');
S=imread('alpha/S.bmp');T=imread('alpha/T.bmp');U=imread('alpha/U.bmp');
V=imread('alpha/V.bmp');W=imread('alpha/W.bmp');X=imread('alpha/X.bmp');
Y=imread('alpha/Y.bmp');Z=imread('alpha/Z.bmp');


%Natural Numbers
one=imread('alpha/1.bmp');two=imread('alpha/2.bmp');  two=imbinarize(two);
three=imread('alpha/3.bmp');four=imread('alpha/4.bmp');
five=imread('alpha/5.bmp'); six=imread('alpha/6.bmp'); 
seven=imread('alpha/7.bmp');eight=imread('alpha/8.bmp');
nine=imread('alpha/9.bmp'); zero=imread('alpha/0.bmp');

%Creating Array for Alphabets
letter={A B C D E F G H I J K L M N O P Q R S T U V W X Y Z};
%Creating Array for Numbers
number={one two three four five six  seven eight nine zero};
Extra={D1 M1};  
NewTemplates=[letter number Extra];
save ('NewTemplates','NewTemplates')
clear all