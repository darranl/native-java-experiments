cmake_minimum_required(VERSION 3.10.0)
project(traffic-lights VERSION 0.1.0 LANGUAGES C)

add_executable(traffic-lights main.c)
target_link_libraries(traffic-lights gpiod)
