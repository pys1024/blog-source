---
title: C Style in Linux
date: 2021-08-05 20:26:00
copyright_author: penn
tags: C, Linux
categories: Linux
keywords: Linux
description: The C style in Linux source code
---

## Naming Conventions

#### Windows Conventions

```c
#define PI 3.14159265 // 宏大写
int minValue, maxValue; // 变量第一个单词首字母小写，驼峰
void SendData(void); // 变量第一个单词首字母大写，驼峰
```

通过首字母可以区分是变量还是函数。

#### Linux Conventions

```c
#define PI 3.14159265 // 宏大写
int min_value, max_value; // 变量小写加下划线
void send_data(void); // 函数名小写加下划线
```

## Code Style

Linux代码缩进使用**TAB**。

1. 结构体，**if/for/while/switch**语句，**{**不另起一行：

   ```c
   struct var_data {
       int len;
       char data[0];
   };
   if (a === b) {
       a = c;
       d = a;
   }
   for (i = 0; i < 10; i++) {
       a = c;
       d = a;
   }
   
   ```

   

2. 如果**if/for**后面只有一行，不要加**{}**：

   ```c
   for (i = 0; i < 10; i++)
       a = c;
   ```

   

3. **if**语句后面包含**else**的，**else**不另起一行：

   ```c
   if (x == y) {
       ...
   } else if (x > y) {
       ...
   } else {
       ...
   }
   ```

   

4. 函数，另起一行！！

   ```c
   int add(int a, int b) {
       return a + b;
   }
   ```

   

5. **switch/case**语句，建议**switch**和**case**对齐：

   ```c
   switch (suffix) {
   case 'g'：
       mem <<= 30;
       break;
   case 'm':
   	m <<= 20;
       break;
   default:
       break;
   }
   ```
## GNU C and ANSI C

**以下特性其实是由GCC编译带来的。**

#### 零长度和变量长度数组

```c
struct var_data {
    int len;
    char data[0];
}

int main (int argc, char* argv[]) 
{
	int i, n = argc;
    double x[n];
    
    for (i = 0; i < n; i++)
        x[i] = i;
    
    return 0;
}
```

注意：data[]并没有被分配内存，因此sizeof(struct var_data)=sizeof(int)。

#### case范围

GNU C支持case x...y语法

```c
switch (ch) {
case '0'... '9': c -= '0';
    break;
case 'a'... 'f': c -= 'a' - 10;
    break;
case 'A'... 'F': c -= 'A' - 10;
    break;
}
```

#### 语句表达式

包含在括号中的复合语句可看成一个表达式。

```c
#dfine min_t(type,x,y) \
({ type __x = (x); type __y = (y); __x<__y ? __x : __y; })

int ia, ib, mini;
float fa, fb, minf;
mini = min_t(int, ia, ib);
minf = min_t(float, fa, fb);
```

重新定义**__x**和**__y**变量后，比如min(++ia, ++ib)这样的用法不会产生副作用，ia和ib不会在表达式中多次自增。

#### typeof关键字

获取类型：

```c
#define min(x,y) (} \
const typeof(x) _x = (x); \
const typeof(y) _y = (y); \
(void) (&_x == &_y); \
_x < _y ? _x : _y; })
```

(void) (&_x == &_y)的作用是检查**_x**和**_y**的类型是否一致。

#### 可变参数宏

宏可以接受可变数目的参数。

```c
#define pr_debug(fmt,arg...) \
printk(fmt, ##arg)
```

arg表示其它的参数，可以有零个或多个。如`pr_debug("%s:%d", filename, line);`会被替换为`printk("%s:%d", filename, line);`

使用**##**的目的是为了处理零个参数的情况，这时候预处理器会丢弃掉前面的逗号。代码`pr_debug("success\n");`会被扩展为`printk("success\n")`

#### 标号元素

ANSI C要求数组和结构体的初始化必须以固定的顺序出现，GNU C中允许通过指定索引或结构体成员名，这样初始化值可以以任意顺序出现。

```c
unsigned char data[MAX] = {
  [0] = 0,
  [1 ... MAX-1] = 1
};
```

借助结构体成员名初始化结构体：

```c
struct file_operation ext2_file_op = {
  llseek: generic_file_llseek,
    read: generic_file_read,
   ioctl: generic_file_ioctl,
};
```

但是，Linux2.6推荐以后类似的初始化尽量采用标准C的方式：

```c
struct file_operation ext2_file_op = {
  .llseek   =  generic_file_llseek,
  .read     = generic_file_read,
  .ioctl    = generic_file_ioctl,
};
```

#### 当前函数名

GNU C包含两个预定义标识符表示当前函数名，**\_\_FUNCTION\_\_**保存函数在源码中的名字，**\_\_PRETTY_FUNCTION\_\_**保存带语言特色的名字。C函数中，这两个名字是相同的。C99开始支持了**\_\_func\_\_**宏，在Linux编程中，建议使用这个新的宏表示函数的名字。

#### 内建函数

GNU C提供大量内建函数，其中大部分是标准C库函数的内建版本，例如memcpy等，其他不属于库函数的内建函数通常以**\_\_builtin**开始命名：

- 内建函数\_\_builtin_return_address(LEVEL)返回当前函数或其调用者的返回地址，参数LEVEL表示调用栈的级数，0表示当前函数的返回地址，1表示调用者的返回地址。

- 内建函数\_\_builtin_constant_p(EXP)用于判断一个值是否为编译时常数。

- 内建函数\_\_builtin_expect(EXP, C)用于为编译器提供分支预测信息，C的值必须为编译时常数。

  Linux内核编程中常用的likely和unlikely底层调用就是基于这个内建函数：

  ```c
  #define likely_notrace(x)      __builtin_expect(!!(x), 1)
  #define unlikely_notrace(x)    __builtin_expect(!!(x), 0)
  ```

  若代码中出现分支，即可能中断流水线，我们可以通过likely()和unlikely()暗示分支的概率。

