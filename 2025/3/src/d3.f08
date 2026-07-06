! ------------------------------------------------------------------------------
! Advent of Code, day 3, Fortran (2008).
! Usage: program <number of batteries>
!
! Part 1: 16946
! part 2: 168627047606506
! ------------------------------------------------------------------------------
! implicit none: forbids implicit typing
! Variable declaration:
!   <type> *<size>, <attributes> :: <variable>, <variable>....
!   <size>: character: number of chars/length. integer: bytes
!   parameter: immutable data
! Command arguments:
!   get_command_argument(<argument>, <buffer>)
!   read(<from>, <format>): i3: read 3 digit integer
! File operations:
!   open()
!       newunit creates a new IO unit. Equivalent to a file descriptor
!       status, old indicates existing file
!       action, read, write, readwrite
!   read()
!       unit, IO unit to read from (or variable)
!       fmt, format specifier (a for character, i for integer)
!       iostat, locaton to store the result of the operation 0 = success
! Named block loops:
!   <name>: do <start>, <end> : start and end not required
!   end do <name>
! len_trim(<string>): returns the length of <string>, ignoring trailing whitespace.
! ichar(<char>): Return the character code for <char>
! maxloc(<array>, <dim>): Find the location of the largest integer in <array>
!   Collapse along dimension <dim>
! ------------------------------------------------------------------------------
program d3
    implicit none

    character(len=*), parameter :: file = "../d3_input"
    character(len=3) :: arg
    character(len=101) :: line

    integer :: io, fd
    integer :: batteries, line_len, bat_count, marker, bat, i
    integer :: digits(100)
    integer(kind=8) :: bat_tot, accum = 0

    ! Process input arguments
    if (command_argument_count() /= 1) then
        write(*,*) "Please supply number of batteries as argument. Format: <program name> <number of batteries>"
        stop
    end if
    call get_command_argument(1, arg)
    read(arg, '(i3)') batteries

    open(newunit=fd, file=file, status="old", action="read")

    ! Loop through the file linewise
    file_loop: do

        read(unit=fd, fmt="(a101)", iostat=io) line
        if (io /= 0) exit

        line_len = len_trim(line)
        bat_count = batteries - 1
        marker = 0
        bat_tot = 0

        ! convert character array line to int array digits
        convert_loop: do i = 1, line_len
            digits(i) = ichar(line(i:i)) - ichar('0')
        end do convert_loop

        ! Loop to build the <batteries> length battery
        battery_loop: do bat = 1, batteries
            ! Find the largest digit from marker in the digits array
            i = marker + maxloc(digits(marker + 1 : line_len-bat_count), dim=1)
            marker = i

            bat_tot = (bat_tot * 10) + digits(i)
            bat_count = bat_count - 1

        end do battery_loop

        accum = accum + bat_tot

    end do file_loop

    write(*,*) "Maximum joltage with ", batteries, " batteries: ", accum
    close(fd)

end program d3