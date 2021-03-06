!
!     CalculiX - A 3-dimensional finite element program
!              Copyright (C) 1998-2014 Guido Dhondt
!
!     This program is free software; you can redistribute it and/or
!     modify it under the terms of the GNU General Public License as
!     published by the Free Software Foundation(version 2);
!     
!
!     This program is distributed in the hope that it will be useful,
!     but WITHOUT ANY WARRANTY; without even the implied warranty of 
!     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the 
!     GNU General Public License for more details.
!
!     You should have received a copy of the GNU General Public License
!     along with this program; if not, write to the Free Software
!     Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
!
      subroutine dynamics(inpc,textpart,nmethod,iperturb,tinc,tper,
     &  tmin,tmax,idrct,alpha,iexpl,isolver,istep,istat,n,iline,
     &  ipol,inl,ipoinp,inp,ithermal,ipoinpc,cfd)
!
!     reading the input deck: *DYNAMIC
!
!     isolver=0: SPOOLES
!             2: iterative solver with diagonal scaling
!             3: iterative solver with Cholesky preconditioning
!             4: sgi solver
!             5: TAUCS
!             7: pardiso
!
!      iexpl==0:  structure:implicit, fluid:semi-implicit
!      iexpl==1:  structure:implicit, fluid:explicit
!      iexpl==2:  structure:explicit, fluid:semi-implicit
!      iexpl==3:  structure:explicit, fluid:explicit 
!
      implicit none
!
      character*1 inpc(*)
      character*20 solver
      character*132 textpart(16)
!
      integer nmethod,istep,istat,n,key,i,iperturb,idrct,iexpl,
     &  isolver,iline,ipol,inl,ipoinp(2,*),inp(3,*),ithermal,
     &  ipoinpc(0:*),cfd
!
      real*8 tinc,tper,tmin,tmax,alpha
!
      if(istep.lt.1) then
         write(*,*) '*ERROR in dynamics: *DYNAMIC can only'
         write(*,*) '  be used within a STEP'
         stop
      endif
!
!     no heat transfer analysis
!
      if(ithermal.gt.1) then
         ithermal=1
      endif
!
!     only nonlinear analysis allowed for this procedure
!
      if(iperturb.lt.2) iperturb=2
!
!     default values
!
      idrct=0
      alpha=-0.05d0
      tmin=0.d0
      tmax=0.d0
!
!     default solver
!
      solver='                    '
      if(isolver.eq.0) then
         solver(1:7)='SPOOLES'
      elseif(isolver.eq.2) then
         solver(1:16)='ITERATIVESCALING'
      elseif(isolver.eq.3) then
         solver(1:17)='ITERATIVECHOLESKY'
      elseif(isolver.eq.4) then
         solver(1:3)='SGI'
      elseif(isolver.eq.5) then
         solver(1:5)='TAUCS'
      elseif(isolver.eq.7) then
         solver(1:7)='PARDISO'
      endif
!
      do i=2,n
         if(textpart(i)(1:6).eq.'ALPHA=') then
            read(textpart(i)(7:26),'(f20.0)',iostat=istat) alpha
            if(istat.gt.0) call inputerror(inpc,ipoinpc,iline,
     &"*DYNAMIC%")
            if(alpha.lt.-1.d0/3.d0) then
               write(*,*) '*WARNING in dynamics: alpha is smaller'
               write(*,*) '  than -1/3 and is reset to -1/3'
               alpha=-1.d0/3.d0
            elseif(alpha.gt.0.d0) then
               write(*,*) '*WARNING in dynamics: alpha is greater'
               write(*,*) '  than 0 and is reset to 0'
               alpha=0.d0
            endif
         elseif(textpart(i)(1:8).eq.'EXPLICIT') then
            if(textpart(i)(9:10).eq.'=1') then
               iexpl=1
            elseif(textpart(i)(9:10).eq.'=2') then
               iexpl=2
            elseif(textpart(i)(9:10).eq.'=3') then
               iexpl=3
            elseif(textpart(i)(9:10).eq.'  ') then
               iexpl=3
            else
               call inputerror(inpc,ipoinpc,iline,
     &"*DYNAMIC%")
            endif
         elseif((textpart(i)(1:6).eq.'DIRECT').and.
     &          (textpart(i)(1:9).ne.'DIRECT=NO')) then
            idrct=1
         elseif(textpart(i)(1:7).eq.'SOLVER=') then
            read(textpart(i)(8:27),'(a20)') solver
         else
            write(*,*) 
     &        '*WARNING in dynamics: parameter not recognized:'
            write(*,*) '         ',
     &                 textpart(i)(1:index(textpart(i),' ')-1)
            call inputwarning(inpc,ipoinpc,iline,
     &"*DYNAMIC%")
         endif
      enddo
!
      if(solver(1:7).eq.'SPOOLES') then
         isolver=0
      elseif(solver(1:16).eq.'ITERATIVESCALING') then
         isolver=2
      elseif(solver(1:17).eq.'ITERATIVECHOLESKY') then
         isolver=3
      elseif(solver(1:3).eq.'SGI') then
         isolver=4
      elseif(solver(1:5).eq.'TAUCS') then
         isolver=5
      elseif(solver(1:7).eq.'PARDISO') then
         isolver=7
      else
         write(*,*) '*WARNING in dynamics: unknown solver;'
         write(*,*) '         the default solver is used'
      endif
!
      call getnewline(inpc,textpart,istat,n,key,iline,ipol,inl,
     &     ipoinp,inp,ipoinpc)
      if((istat.lt.0).or.(key.eq.1)) then
         if((iperturb.ge.2).or.(cfd.eq.1)) then
            write(*,*)'*WARNING in dynamics: a nonlinear geometric analy
     &sis is requested'
            write(*,*) '         but no time increment nor step is speci
     &fied'
            write(*,*) '         the defaults (1,1) are used'
            tinc=1.d0
            tper=1.d0
            tmin=1.d-5
            tmax=1.d+30
         endif
         nmethod=4
         return
      endif
!
      read(textpart(1)(1:20),'(f20.0)',iostat=istat) tinc
      if(istat.gt.0) call inputerror(inpc,ipoinpc,iline,
     &"*DYNAMIC%")
      read(textpart(2)(1:20),'(f20.0)',iostat=istat) tper
      if(istat.gt.0) call inputerror(inpc,ipoinpc,iline,
     &"*DYNAMIC%")
      read(textpart(3)(1:20),'(f20.0)',iostat=istat) tmin
      if(istat.gt.0) call inputerror(inpc,ipoinpc,iline,
     &"*DYNAMIC%")
      read(textpart(4)(1:20),'(f20.0)',iostat=istat) tmax
      if(istat.gt.0) call inputerror(inpc,ipoinpc,iline,
     &"*DYNAMIC%")
!
      if(tinc.le.0.d0) then
         write(*,*)'*ERROR in dynamics: initial increment size is negati
     &ve'
      endif
      if(tper.le.0.d0) then
         write(*,*) '*ERROR in dynamics: step size is negative'
      endif
      if(tinc.gt.tper) then
         write(*,*)'*ERROR in dynamics: initial increment size exceeds s
     &tep size'
      endif
!      
      if(idrct.ne.1) then
         if(dabs(tmin).lt.1.d-10) then
            if(iexpl.le.1) then
               tmin=min(tinc,1.d-5*tper)
            else
               tmin=min(tinc,1.d-10*tper)
            endif
         endif
         if(dabs(tmax).lt.1.d-10) then
            tmax=1.d+30
         endif
      endif
!
      nmethod=4
!
      call getnewline(inpc,textpart,istat,n,key,iline,ipol,inl,
     &     ipoinp,inp,ipoinpc)
!
      return
      end

