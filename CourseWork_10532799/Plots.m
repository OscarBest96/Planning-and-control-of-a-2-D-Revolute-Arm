function Plots(P1config,P2config,thetaTRAIN,P2train,TRAINerror1,TRAINerror2,TRAINJointAngles1,TRAINJointAngles2,TRAINP2,thetaTEST,P2test,TESTJointAngles1,TESTJointAngles2,TESTP2)

%plot arm configuration
figure(1);
fontSize = 20;
hold on
h=title(sprintf('10532799: arm configurations'));
set(h,'FontSize', fontSize);
xlabel('X coordinate');
ylabel('Y coordinate');
%loop connects origin,elbowjoint and end effector
for idx = 1:10
    plot([0,P1config(1,idx)],[0,P1config(2,idx)],'b-',[P1config(1,idx),P2config(1,idx)],[P1config(2,idx),P2config(2,idx)],'b-','linewidth',2);
end
 %plots origin
 plot(0,0,'k*');
 %plots elbow joint
 plot(P1config(1,:),P1config(2,:),'go');
 %plots end effector
 plot(P2config(1,:),P2config(2,:),'ro');
hold off



%%%%%%%%%%%%%%%%% TRAINING PLOTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%plot random joint angles
figure(2);
fontSize = 20;
hold on
h=title(sprintf('10532799: *TRAIN* Random joint angle data'));
set(h,'FontSize', fontSize);
xlabel('X coordinate');
ylabel('Y coordinate');
plot(thetaTRAIN(1,:),thetaTRAIN(2,:),'b.');
legend('random joint angles');
hold off

%plot random endpoint data
figure(3);
fontSize = 20;
hold on
h=title(sprintf('10532799: *TRAIN* Random endpoint data'));
set(h,'FontSize', fontSize);
xlabel('X coordinate');
ylabel('Y coordinate');
plot(P2train(1,:),P2train(2,:),'b.');
plot(0,0,'k*');
legend('end effector positions', 'point of origin');
hold off

%plot sum squared error
figure(4)
hold on
title('10532799: *TRAIN* summed squared error');
xlabel('itteration');
ylabel('value of error squared');
plot(TRAINerror1,'b-')
plot(TRAINerror2,'r-')
hold off

%plot calculated joint angles
figure(5)
hold on
title('10532799: *TRAIN* inverse model joint angle');
xlabel('X coordinate');
ylabel('Y coordinate');
plot(TRAINJointAngles1,TRAINJointAngles2,'r.')
legend('calculated joint angles');
hold off

%plot re-calulated end effector positions
figure(6)
hold on
title('10532799: *TRAIN* regenerated via inv and fwd model endpoint');
xlabel('X coordinate');
ylabel('Y coordinate');
plot(TRAINP2(1,:),TRAINP2(2,:),'r.')
legend('re-calculated end effector positions');
hold off




%%%%%%%%%%%%%%%%% TESTING PLOTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%plot random joint angles
figure(7);
fontSize = 20;
hold on
h=title(sprintf('10532799: *TEST* Random joint angle data'));
set(h,'FontSize', fontSize);
xlabel('X coordinate');
ylabel('Y coordinate');
plot(thetaTEST(1,:),thetaTEST(2,:),'b.');
legend('random joint angles');
hold off

%plot random endpoint data
figure(8);
fontSize = 20;
hold on
h=title(sprintf('10532799: *TEST* Random endpoint data'));
set(h,'FontSize', fontSize);
xlabel('X coordinate');
ylabel('Y coordinate');
plot(P2test(1,:),P2test(2,:),'b.');
plot(0,0,'k*');
legend('end effector positions', 'point of origin');
hold off

%plot calculated joint angles
figure(9)
hold on
title('10532799: *TEST* inverse model joint angle');
xlabel('X coordinate');
ylabel('Y coordinate');
plot(TESTJointAngles1,TESTJointAngles2,'m.')
legend('calculated joint angles');
hold off

%plot re-calulated end effector positions
figure(10)
hold on
title('10532799: *TEST* regenerated via inv and fwd model endpoint');
xlabel('X coordinate');
ylabel('Y coordinate');
plot(TESTP2(1,:),TESTP2(2,:),'m.')
legend('re-calculated end effector positions');
hold off



end

