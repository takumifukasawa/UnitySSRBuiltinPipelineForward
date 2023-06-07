# Screen Space Reflection

article: https://takumifukasawa.hatenablog.com/entry/unity-ssr-custom-postprocess-forward

env: Unity 2021.3.26f built-in pipeline

![https://private-user-images.githubusercontent.com/947953/244139674-6302ee44-7a71-4fc0-9dc3-1a3743195a5d.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJrZXkiOiJrZXkxIiwiZXhwIjoxNjg2MTU2NzIwLCJuYmYiOjE2ODYxNTY0MjAsInBhdGgiOiIvOTQ3OTUzLzI0NDEzOTY3NC02MzAyZWU0NC03YTcxLTRmYzAtOWRjMy0xYTM3NDMxOTVhNWQucG5nP1gtQW16LUFsZ29yaXRobT1BV1M0LUhNQUMtU0hBMjU2JlgtQW16LUNyZWRlbnRpYWw9QUtJQUlXTkpZQVg0Q1NWRUg1M0ElMkYyMDIzMDYwNyUyRnVzLWVhc3QtMSUyRnMzJTJGYXdzNF9yZXF1ZXN0JlgtQW16LURhdGU9MjAyMzA2MDdUMTY0NzAwWiZYLUFtei1FeHBpcmVzPTMwMCZYLUFtei1TaWduYXR1cmU9ZGY0ZjZmMzBkZWI1NTUyMjEyOWQ1MWFkYWMzMjE1ODk0ZDUxYjczNGE5NWYwMjdjZWFjNzhjZWU3MjIzNjQyNCZYLUFtei1TaWduZWRIZWFkZXJzPWhvc3QifQ.a6UFSgy6gS13Mlz-T_1Sx994TREOCjFD2C6ULBDRcU0](https://private-user-images.githubusercontent.com/947953/244139674-6302ee44-7a71-4fc0-9dc3-1a3743195a5d.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJrZXkiOiJrZXkxIiwiZXhwIjoxNjg2MTU2NzIwLCJuYmYiOjE2ODYxNTY0MjAsInBhdGgiOiIvOTQ3OTUzLzI0NDEzOTY3NC02MzAyZWU0NC03YTcxLTRmYzAtOWRjMy0xYTM3NDMxOTVhNWQucG5nP1gtQW16LUFsZ29yaXRobT1BV1M0LUhNQUMtU0hBMjU2JlgtQW16LUNyZWRlbnRpYWw9QUtJQUlXTkpZQVg0Q1NWRUg1M0ElMkYyMDIzMDYwNyUyRnVzLWVhc3QtMSUyRnMzJTJGYXdzNF9yZXF1ZXN0JlgtQW16LURhdGU9MjAyMzA2MDdUMTY0NzAwWiZYLUFtei1FeHBpcmVzPTMwMCZYLUFtei1TaWduYXR1cmU9ZGY0ZjZmMzBkZWI1NTUyMjEyOWQ1MWFkYWMzMjE1ODk0ZDUxYjczNGE5NWYwMjdjZWFjNzhjZWU3MjIzNjQyNCZYLUFtei1TaWduZWRIZWFkZXJzPWhvc3QifQ.a6UFSgy6gS13Mlz-T_1Sx994TREOCjFD2C6ULBDRcU0)

## ref

[https://tips.hecomi.com/entry/2016/04/04/022550](https://tips.hecomi.com/entry/2016/04/04/022550)

[https://zenn.dev/mebiusbox/articles/43ecf1bb12831c](https://zenn.dev/mebiusbox/articles/43ecf1bb12831c)

[http://www.kode80.com/blog/2015/03/11/screen-space-reflections-in-unity-5/](http://www.kode80.com/blog/2015/03/11/screen-space-reflections-in-unity-5/)

[https://hanecci.hatenadiary.org/entry/20140617/p8](https://hanecci.hatenadiary.org/entry/20140617/p8)

[https://i-saint.hatenablog.com/entry/2014/12/05/174706](https://i-saint.hatenablog.com/entry/2014/12/05/174706)

[https://jcgt.org/published/0003/04/04/paper-lowres.pdf](https://jcgt.org/published/0003/04/04/paper-lowres.pdf)
