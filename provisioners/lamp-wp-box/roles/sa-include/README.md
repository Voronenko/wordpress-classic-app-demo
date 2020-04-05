sa-include
==========

[![Build Status](https://travis-ci.org/softasap/sa-include.svg?branch=master)](https://travis-ci.org/softasap/sa-include)


Usage example:

Simple:

<pre>

     - {
         role: "some role X"         
       }

     - {
         role: "sa-include",
         include_file: "{{root_dir}}/tasks/your_tasks_in_the_middle.yml"
       }

     - {
         role: "some role Y" 
       }



</pre>


