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
      subroutine creeps(inpc,textpart,nelcon,nmat,ntmat_,npmat_,
     &        plicon,nplicon,elcon,iplas,iperturb,nstate_,ncmat_,
     &        matname,irstrt,istep,istat,n,iline,ipol,inl,ipoinp,inp,
     &        ipoinpc,ianisoplas)
!
!     reading the input deck: *CREEP
!
      implicit none
!
      logical iso
!
      character*1 inpc(*)
      character*80 matname(*)
      character*132 textpart(16)
!
      integer nelcon(2,*),nmat,ntmat_,ntmat,istep,npmat_,nstate_,
     &  n,key,i,j,iplas,iperturb(*),istat,nplicon(0:ntmat_,*),ncmat_,
     &  k,id,irstrt,iline,ipol,inl,ipoinp(2,*),inp(3,*),ipoinpc(0:*),
     &  ianisoplas
!
      real*8 temperature,elcon(0:ncmat_,ntmat_,*),t1l,
     &  plicon(0:2*npmat_,ntmat_,*)
!
      iso=.true.
      ntmat=0
!
      if((istep.gt.0).and.(irstrt.ge.0)) then
         write(*,*) '*ERROR reading *CREEP: *CREEP should be placed'
         write(*,*) '  before all step definitions'
         stop
      endif
!
      if(nmat.eq.0) then
         write(*,*) '*ERROR reading *CREEP: *CREEP should be preceded'
         write(*,*) '  by a *MATERIAL card'
         stop
      endif
!
!     check for anisotropic creep: assumes a ucreep routine
!
      if((nelcon(1,nmat).ne.2).and.(nelcon(1,nmat).ne.-51)) then
         if((nelcon(1,nmat).ne.9).and.(nelcon(1,nmat).ne.-114)) then
            write(*,*) '*ERROR reading *CREEP: *CREEP should be'
            write(*,*) '       preceded by an *ELASTIC,TYPE=ISO card,'
            write(*,*) '       or an *ELASTIC,TYPE=ORTHO card'
            stop
         endif
!
         ianisoplas=1
!
         if(nelcon(1,nmat).ne.-114) then
!
!           viscoplastic material with zero yield surface and
!           without hardening: no plasticity
!
            iperturb(1)=3
            iperturb(2)=1
            write(*,*) '*INFO reading *CREEP: nonlinear geometric'
            write(*,*) '      effects are turned on'
            write(*,*)
            nelcon(1,nmat)=-114
            do i=2,n
               if(textpart(i)(1:8).eq.'LAW=USER') then
                  nelcon(1,nmat)=-109
                  exit
               endif
            enddo
            if(nelcon(1,nmat).eq.-109) then
!
!              elastic orthotropic
!              no plasticity
!              user creep: -109
!
               nstate_=max(nstate_,7)
               if(matname(nmat)(70:80).ne.'           ') then
                  write(*,*) '*ERROR reading *CREEP: the material name'
                  write(*,*) '       for an elastically anisotropic'
                  write(*,*) '       material with isotropic creep must'
                  write(*,*) '       not exceed 69 characters'
                  stop
               else
                  do i=80,12,-1
                     matname(nmat)(i:i)=matname(nmat)(i-11:i-11)
                  enddo
c                  matname(nmat)(12:80)=matname(nmat)(1:69)
                  matname(nmat)(1:11)='ANISO_CREEP'
               endif
               call getnewline(inpc,textpart,istat,n,key,iline,ipol,inl,
     &              ipoinp,inp,ipoinpc)
               return
            else
!
!              elastic orthotropic
!              no plasticity
!              Norton creep: -114
!
               nstate_=max(nstate_,14)
               do i=1,nelcon(2,nmat)
                  elcon(10,i,nmat)=0.d0
                  elcon(11,i,nmat)=0.d0
                  elcon(12,i,nmat)=0.d0
               enddo
               if(matname(nmat)(71:80).ne.'          ') then
                  write(*,*) '*ERROR reading *CREEP: the material name'
                  write(*,*) '       for an elastically anisotropic'
                  write(*,*) '       material with Norton creep'
                  write(*,*) '       must not exceed 70 characters'
                  stop
               else
                  do i=80,11,-1
                     matname(nmat)(i:i)=matname(nmat)(i-10:i-10)
                  enddo
c                  matname(nmat)(11:80)=matname(nmat)(1:70)
                  matname(nmat)(1:10)='ANISO_PLAS'
               endif
            endif
         else
!
!              elastic orthotropic
!              plasticity
!              Norton creep: -114 (user creep is not allowed)
!
            do i=2,n
               if(textpart(i)(1:8).eq.'LAW=USER') then
                  write(*,*) '*ERROR reading *CREEP: for an elastically'
                  write(*,*) '       anisotropic material with von'
                  write(*,*) '       Mises plasticity only Norton creep'
                  write(*,*) '       is allowed (no user subroutine)'
                  stop
               endif
            enddo
         endif
      endif
!
!     if the *CREEP card is not preceded by a *PLASTIC card, a zero
!     yield surface is assumed
!
      if(nelcon(1,nmat).ne.-114) then
!
!        elastic isotropic
!        plasticity or no plasticity
!        creep (Norton or user): -52
!
         if(nelcon(1,nmat).ne.-51) then
!
!           elastic isotropic
!           no plasticity -> zero yield plasticity
!           creep (Norton or user)
!
            nplicon(0,nmat)=1
            nplicon(1,nmat)=2
            plicon(0,1,nmat)=0.d0
            plicon(1,1,nmat)=0.d0
            plicon(2,1,nmat)=0.d0
            plicon(3,1,nmat)=0.d0
            plicon(4,1,nmat)=10.d10
         endif
!     
         iperturb(1)=3
         iperturb(2)=1
         write(*,*) '*INFO reading *CREEP: nonlinear geometric'
         write(*,*) '      effects are turned on'
         write(*,*)
         iplas=1
         nelcon(1,nmat)=-52
         nstate_=max(nstate_,13)
!     
         do i=2,n
            if(textpart(i)(1:8).eq.'LAW=USER') then
               do j=1,nelcon(2,nmat)
                  elcon(3,j,nmat)=-1.d0
               enddo
               call getnewline(inpc,textpart,istat,n,key,iline,ipol,inl,
     &              ipoinp,inp,ipoinpc)
               return
            else
               write(*,*) 
     &              '*WARNING reading *CREEP: parameter not recognized:'
               write(*,*) '         ',
     &              textpart(i)(1:index(textpart(i),' ')-1)
               call inputwarning(inpc,ipoinpc,iline,
     &"*CREEP%")
            endif
         enddo
!
!        before interpolation: data are stored in positions 6-9:
!        A,n,m,temperature
!        after interpolation: data are stored in positions 3-5:
!        A,n,m
!     
         do
            call getnewline(inpc,textpart,istat,n,key,iline,ipol,inl,
     &           ipoinp,inp,ipoinpc)
            if((istat.lt.0).or.(key.eq.1)) exit
            ntmat=ntmat+1
            if(ntmat.gt.ntmat_) then
               write(*,*) '*ERROR reading *CREEP: increase ntmat_'
               stop
            endif
            do i=1,3
               read(textpart(i)(1:20),'(f20.0)',iostat=istat) 
     &               elcon(i+5,ntmat,nmat)
               if(istat.gt.0) call inputerror(inpc,ipoinpc,iline,
     &"*CREEP%")
            enddo
            if(elcon(6,ntmat,nmat).le.0.d0) then
               write(*,*) '*ERROR reading *CREEP: parameter A'
               write(*,*) '       in the Norton law is nonpositive'
               stop
            endif
            if(elcon(7,ntmat,nmat).le.0.d0) then
               write(*,*) '*ERROR reading *CREEP: parameter n'
               write(*,*) '       in the Norton law is nonpositive'
               stop
            endif
            if(textpart(4)(1:1).ne.' ') then
               read(textpart(4)(1:20),'(f20.0)',iostat=istat)
     &               temperature
               if(istat.gt.0) call inputerror(inpc,ipoinpc,iline,
     &"*CREEP%")
            else
               temperature=0.d0
            endif
            elcon(9,ntmat,nmat)=temperature
         enddo
!
         if(ntmat.eq.0) then
            write(*,*) '*ERROR reading *CREEP: Norton law assumed,'
            write(*,*) '       yet no constants given'
            stop
         endif
!
!        interpolating the creep data at the elastic temperature
!        data points
!
         do i=1,nelcon(2,nmat)
            t1l=elcon(0,i,nmat)
            call ident2(elcon(9,1,nmat),t1l,ntmat,ncmat_+1,id)
            if(ntmat.eq.0) then
               continue
            elseif((ntmat.eq.1).or.(id.eq.0)) then
               elcon(3,i,nmat)=elcon(6,1,nmat)
               elcon(4,i,nmat)=elcon(7,1,nmat)
               elcon(5,i,nmat)=elcon(8,1,nmat)
            elseif(id.eq.ntmat) then
               elcon(3,i,nmat)=elcon(6,id,nmat)
               elcon(4,i,nmat)=elcon(7,id,nmat)
               elcon(5,i,nmat)=elcon(8,id,nmat)
            else
               do k=3,5
                  elcon(k,i,nmat)=elcon(k+3,id,nmat)+
     &               (elcon(k+3,id+1,nmat)-elcon(k+3,id,nmat))*
     &               (t1l-elcon(9,id,nmat))/
     &               (elcon(9,id+1,nmat)-elcon(9,id,nmat))
               enddo
            endif
         enddo
!
      else
!
!        elastically anisotropic material with isotropic viscoplasticity
!        (i.e. isotropic plasticity with Norton creep)
!
         do
            call getnewline(inpc,textpart,istat,n,key,iline,ipol,inl,
     &           ipoinp,inp,ipoinpc)
            if((istat.lt.0).or.(key.eq.1)) exit
            ntmat=ntmat+1
            if(ntmat.gt.ntmat_) then
               write(*,*) '*ERROR reading *CREEP: increase ntmat_'
               stop
            endif
            do i=1,3
               read(textpart(i)(1:20),'(f20.0)',iostat=istat) 
     &               elcon(i+15,ntmat,nmat)
               if(istat.gt.0) call inputerror(inpc,ipoinpc,iline,
     &"*CREEP%")
            enddo
            if(textpart(3)(1:1).ne.' ') then
               read(textpart(3)(1:20),'(f20.0)',iostat=istat) 
     &                  temperature
               if(istat.gt.0) call inputerror(inpc,ipoinpc,iline,
     &"*CREEP%")
            else
               temperature=0.d0
            endif
            elcon(19,ntmat,nmat)=temperature
         enddo
!
!        interpolating the creep data at the elastic temperature
!        data points
!
!        before interpolation: data are stored in positions 16-19:
!        A,n,m,temperature
!        after interpolation: data are stored in positions 13-15:
!        A,n,m
!
         if(ntmat.eq.0) then
            write(*,*) '*ERROR reading *CREEP: Norton law assumed,'
            write(*,*) '       yet no constants given'
            stop
         endif
!     
         do i=1,nelcon(2,nmat)
            t1l=elcon(0,i,nmat)
            call ident2(elcon(19,1,nmat),t1l,ntmat,ncmat_+1,id)
            if(ntmat.eq.0) then
               continue
            elseif((ntmat.eq.1).or.(id.eq.0)) then
               elcon(13,i,nmat)=elcon(16,1,nmat)
               elcon(14,i,nmat)=elcon(17,1,nmat)
               elcon(15,i,nmat)=elcon(18,1,nmat)
            elseif(id.eq.ntmat) then
               elcon(13,i,nmat)=elcon(16,id,nmat)
               elcon(14,i,nmat)=elcon(17,id,nmat)
               elcon(15,i,nmat)=elcon(18,id,nmat)
            else
               do k=13,15
                  elcon(k,i,nmat)=elcon(k+3,id,nmat)+
     &               (elcon(k+3,id+1,nmat)-elcon(k+3,id,nmat))*
     &               (t1l-elcon(19,id,nmat))/
     &               (elcon(19,id+1,nmat)-elcon(19,id,nmat))
               enddo
            endif
         enddo
!
      endif
!
c      if(nelcon(1,nmat).eq.-114) then
c         write(*,*) 'anisotropic elasticity+viscoplasticity'
c         do i=1,nelcon(2,nmat)
c            write(*,*) (elcon(j,i,nmat),j=0,14)
c         enddo
cc         stop
c      endif
!
      return
      end

