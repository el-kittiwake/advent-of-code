! -----------------------------------------------------------------------------
! Day 3 of Advent of Code. Part 1.
! -----------------------------------------------------------------------------

program d3p1
	implicit none

	integer :: io, fd
	integer :: a = 0, b = 0
	integer :: x = 0, y = 0
	integer :: bank_max = 0, accum = 0, marker = 0
	integer :: i
	character(len=101) :: line
	character(len=*), parameter :: file = "../d3-input"

	open(newunit=fd, file=file, status="old", action="read")

	file_loop: do
		read(fd, "(A101)", iostat=io) line
		if (io /= 0) exit

		a_loop: do i = 1, len_trim(line) - 1
			read(line(i:i), '(i10)') x
			if (x > a) then
				a = x
				marker = i
			end if
			if (a == 9) exit a_loop
		end do a_loop
		bank_max = a * 10
		a = 0

		b_loop: do i = marker + 1, len_trim(line)
			read(line(i:i), '(i10)') y
			if (y > b) b = y
			if (b == 9) exit b_loop
		end do b_loop
		bank_max = bank_max + b
		b = 0

		accum = accum + bank_max

	end do file_loop

	write(*,*) "Maximum joltage: ", accum
	close(fd)

end program d3p1