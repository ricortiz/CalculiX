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
      subroutine surfaceinteractions(inpc,textpart,matname,nmat,nmat_,
     &  irstrt,istep,istat,n,iline,ipol,inl,ipoinp,inp,nrhcon,ipoinpc,
     &  imat)
!
!     reading the input deck: *SURFACE INTERACTION
!
      implicit none
!
      character*1 inpc(*)
      character*80 matname(*)
      character*132 textpart(16)
!
      integer nmat,nmat_,istep,istat,n,key,i,irstrt,iline,ipol,inl,
     &  ipoinp(2,*),inp(3,*),nrhcon(*),ipoinpc(0:*),imat
!
      if((istep.gt.0).and.(irstrt.ge.0)) then
         write(*,*) '*ERROR in surfaceinteractions:'
         write(*,*) '       *SURFACE INTERACTION should be placed'
         write(*,*) '       before all step definitions'
         stop
      endif
!
      nmat=nmat+1
      if(nmat.gt.nmat_) then
         write(*,*) '*ERROR in surfaceinteractions: increase nmat_'
         stop
      endif
      imat=nmat
!
      do i=2,n
         if(textpart(i)(1:5).eq.'NAME=') then
            matname(nmat)=textpart(i)(6:85)
            if(textpart(i)(86:86).ne.' ') then
               write(*,*) '*ERROR in surfaceinteractions: name too long'
               write(*,*) '       (more than 80 characters)'
               write(*,*) '       interaction name:',textpart(i)(1:132)
               stop
            endif
            exit
         endif
      enddo
!
!     a fictitious nonzero number of density values is stored in nrhcon
!     for contact calculations in which all materials are required to 
!     have a density assigned (e.g. dynamic calculations). This is needed
!     since a surface interaction is internally treated as material
!
      nrhcon(nmat)=-1
!
      call getnewline(inpc,textpart,istat,n,key,iline,ipol,inl,
     &     ipoinp,inp,ipoinpc)
!
      return
      end

