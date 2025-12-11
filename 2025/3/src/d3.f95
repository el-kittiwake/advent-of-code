! -----------------------------------------------------------------------------
! Day 3 of Advent of Code.
! Usage: program <number of batteries>
!
! Notes on functions:
! open()
!	newunit creates a new IO unit. Equivalent to a file descriptor
!	status, old indicates existing file
!	action, read, write, readwrite
! read()
!	unit, IO unit to read from (or variable)
!	fmt, format specifier (a for character, i for integer)
!	iostat, locaton to store the result of the operation 0 = success
! -----------------------------------------------------------------------------

program d3p1
	implicit none

	character(len=*), parameter :: file = "../d3-input"
	character(len=3) :: arg
	character(len=101) :: line

	integer :: io, fd
	integer :: batteries, line_len, bat_count, marker, bat, dig, i, num
	integer*8 :: bat_tot, accum = 0

	if (command_argument_count() /= 1) then
		write(*,*) "Please supply number of batteries as argument. Format: <program name> <number of batteries>"
		stop
	end if
	call get_command_argument(1, arg)
	read(arg, '(i2)') batteries

	open(newunit=fd, file=file, status="old", action="read")

	file_loop: do

		read(unit=fd, fmt="(a101)", iostat=io) line
		if (io /= 0) exit

		line_len = len_trim(line)
		bat_count = batteries - 1
		marker = 0
		bat_tot = 0

		battery_loop: do bat = 1, batteries
			dig = 0

			line_loop: do i = marker + 1, line_len - bat_count

				read(line(i:i), '(i1)') num

				if (num > dig) then
					dig = num
					marker = i
				end if
				if (dig == 9) exit line_loop

			end do line_loop
			
			bat_tot = bat_tot * 10
			bat_tot = bat_tot + dig
			bat_count = bat_count - 1

		end do battery_loop

		accum = accum + bat_tot

	end do file_loop

	write(*,*) "Maximum joltage with ", batteries, " batteries: ", accum
	close(fd)

end program d3p1