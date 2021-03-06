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
      subroutine ties(inpc,textpart,tieset,tietol,istep,
     &       istat,n,iline,ipol,inl,ipoinp,inp,ntie,ntie_,ipoinpc)
!
!     reading the input deck: *TIE
!
      implicit none
!
      logical multistage,tied
!
      character*1 inpc(*)
      character*81 tieset(3,*)
      character*132 textpart(16)
!
      integer istep,istat,n,i,key,ipos,iline,ipol,inl,ipoinp(2,*),
     &  inp(3,*),ntie,ntie_,ipoinpc(0:*)
!
      real*8 tietol(3,*)
!
      multistage=.false.
      tied=.true.
!
      if(istep.gt.0) then
         write(*,*) '*ERROR in ties: *TIE should'
         write(*,*) '  be placed before all step definitions'
         stop
      endif
!
      ntie=ntie+1
      if(ntie.gt.ntie_) then
         write(*,*) '*ERROR in ties: increase ntie_'
         stop
      endif
!
      tietol(1,ntie)=-1.d0
      tieset(1,ntie)(1:1)=' '
!
      do i=2,n
         if(textpart(i)(1:18).eq.'POSITIONTOLERANCE=') then
            read(textpart(i)(19:38),'(f20.0)',iostat=istat) 
     &             tietol(1,ntie)
            if(istat.gt.0) call inputerror(inpc,ipoinpc,iline,
     &"*TIE%")
         elseif(textpart(i)(1:5).eq.'NAME=') then
            read(textpart(i)(6:85),'(a80)',iostat=istat) 
     &          tieset(1,ntie)(1:80)
            if(istat.gt.0) call inputerror(inpc,ipoinpc,iline,
     &"*TIE%")
         elseif(textpart(i)(1:14).eq.'CYCLICSYMMETRY') then
            tied=.false.
         elseif(textpart(i)(1:10).eq.'MULTISTAGE') then
            multistage=.true.
            tied=.false.
         else
            write(*,*) 
     &        '*WARNING in ties: parameter not recognized:'
            write(*,*) '         ',
     &                 textpart(i)(1:index(textpart(i),' ')-1)
            call inputwarning(inpc,ipoinpc,iline,
     &"*TIE%")
         endif
      enddo
      if(tieset(1,ntie)(1:1).eq.' ') then
         write(*,*) '*ERROR in ties: tie name is lacking'
         call inputerror(inpc,ipoinpc,iline,
     &"*TIE%")
         stop
      endif
!
      call getnewline(inpc,textpart,istat,n,key,iline,ipol,inl,
     &     ipoinp,inp,ipoinpc)
      if((istat.lt.0).or.(key.eq.1)) then
         write(*,*)'*ERROR in ties: definition of the tie'
         write(*,*) '      is not complete.'
         stop
      endif
!      
      if ( multistage ) then
         tieset(1,ntie)(81:81)='M'
      elseif(tied) then
         tieset(1,ntie)(81:81)='T'
      endif
!
      if(tied) then
!
!        slave surface can be nodal or facial
!
         tieset(2,ntie)(1:80)=textpart(1)(1:80)
         tieset(2,ntie)(81:81)=' '
!     
!        master surface must be facial
!
         tieset(3,ntie)(1:80)=textpart(2)(1:80)
         tieset(3,ntie)(81:81)=' '
         ipos=index(tieset(3,ntie),' ')
         tieset(3,ntie)(ipos:ipos)='T'
      else
!
!        slave and master surface must be nodal
!
         tieset(2,ntie)(1:80)=textpart(1)(1:80)
         tieset(2,ntie)(81:81)=' '
         ipos=index(tieset(2,ntie),' ')
         tieset(2,ntie)(ipos:ipos)='S'
!     
         tieset(3,ntie)(1:80)=textpart(2)(1:80)
         tieset(3,ntie)(81:81)=' '
         ipos=index(tieset(3,ntie),' ')
         tieset(3,ntie)(ipos:ipos)='S'
      endif
!
      call getnewline(inpc,textpart,istat,n,key,iline,ipol,inl,
     &     ipoinp,inp,ipoinpc)
!
      return
      end



