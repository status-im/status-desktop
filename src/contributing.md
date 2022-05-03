# Contributing guidelines
The main goal of the following document is to have a `basic set of guidelines` that all contributors should apply when writing code in the `status-desktop` project and specific rules for using the C++ language in order to achieve consistent, maintainable and easy-to-understand code for everyone.

There are lots of existing and extended guidelines that can be used, as well, as a complement of the ones that will be described below. Here some examples:
- [Cpp Core Guidelines](https://github.com/isocpp/CppCoreGuidelines/blob/master/CppCoreGuidelines.md)

## Generic rules

General software development best practices and / or OPP specific ones:
- Write code using a syntax that can make the `code easy to understand` although it requires more writing. The time spent to understand that code by other contributors will be compensated.
- Create `self-documented` code by using self-explanatory names wherever possible for classes, methods and variables. It will increase readability and comprehension.
- Keep in mind the `SOLID` principles. Your code will become flexible, reusable, scalable and prepared for test-driven development.
- Keep `methods body short`. Divide when possible. Recursive calls and nested loops should be minimized.
- Use `parenthesis` to resolve ambiguity in complex expressions. Each individual expression should be written in its single parenthesis.
- Use the following `arguments order` in method's `signature` (it will force default argument's values to be input ones): 
  - Input / Output.
  - Output.
  - Input.
- `Initialize` all `variables` when declared.
- `Initialize` all class `attributes` in their own class constructor.
- Use `m_` syntaxis to define attribute names.
- Class and method names should begin with `capital letter` and use `camel case` approach.
- Use the following `class / members declaration structure`:
  - Public methods / members.
  - Protected methods / members.
  - Private methods / members. 
- Code should compile `without warnings`.


## C++ language specific rules
- As a general rule, for `smart pointers`, `containers` and `threads`, use `STL for domain` and `Qt specific for controllers` (layer exposed to QML).
  - Use smart pointers for general dynamic/heap memory management: STL with make_shared and make_unique. 
  - Use Qt’s parent-child relationship and built-in ownership in API where appropriate: QObject-based with QPointer.
- Use `const` keyword wherever possible it will build a more robust code. If it is used in variables, the held value cannot be modified; in pointers, the address pointed to cannot be modified (no restrictions for the stored data); in class methods, the method cannot modify any class attribute.
- When passing arguments, use `references` instead of pointers as far as possible by using `&`. It will prevent some typical errors such as passing null pointers to methods.
- When passing arguments, `avoid passing by value` big size arguments as structures and objects. It will reduce the stack used and it will not be necessary to have properly implemented the copy constructor in all classes. 
- Use `dynamic allocation` only if needed because it requires much processor time than stack memory allocation. By minimizing its usage for variables and objects will increase efficiency and `reduce` the risk of `memory leaks`.
- `Thread’s` usage must be `justified`. Always keep in mind the principle “Keep It Simple”.
- The `C++ standard` to be used must be `at least C++17`.
- `Singleton’s` usage must be `justified`. They must be just only global settings and specific objects but to use them it will need a consensus with the team.
- `.clang-tidy` configuration will be used as the C++ linter and at least the following checkers will be set (it must be included in the CI process):
  - cppcoreguidelines-*
  - modernize-*
  - readibility-*

## Documentation

- Use `header files` to document classes and methods by using `doxygen syntax`. More information here: [Doxygen manual](https://www.doxygen.nl/index.html).


```
/*
 * Add here header file description.
 * \file Example.h
 * \brief Source code file.
 */

 ...

/*
 * \brief Add here short class description.
 * This class implements a ...
 */
 class Example {
    public:
        /*
        * \brief Class constructor
        */
        Example();

        /*
        * \brief Class destructor.
        */
        ~Example();

    protected:
        /*
        * \brief Add here short method description.
        * This method ...
        * \return True if the operation was successfully completed; False otherwise.
        */
        bool Example2();

    private:
        /*
        * \brief Add here short method description.
        * This method...
        */
        Example3(bool bEnabled  //!< [in] Enable argument value.           
        );

    ...
 }
```


