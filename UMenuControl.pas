// Testing git attributes merge rule
unit UMenuControl;

interface

uses
  Forms, Controls, Dialogs, SysUtils, Classes, Variants, System.UITypes;

procedure ActivateOption(SecurityID: Integer);
function CheckForRestart: Boolean;

implementation

uses
  ULowConstants, UFrmSecurityMaintenance, UFrmLowSQLQuery, UObjSecurityRoutines,
  ULowMessageDlg, UFrmSecurityLoggedInUsers, UFrmActivateSecOptWzd, UFrmSecurityAuditHistoryWizard,
  UFrmSpecsMaint, UFrmOtherSourcesLkp, UFrmDepositoriesLkp, UFrmDailyEntryMaint, UFrmBeginningBalanceMaint,
  UFrmInvDepositoriesLkp, UFrmCashDepositBalRptWzd, UFrmNotesByDateSpan,
  UFrmReportMsgLookup, UFrmChangeCurBusinessDate, UFrmTaxUnitsLookup, UFrmTaxUnitsCrosswalkMaint,
  UFrmImportFromTaxWzd, UFrmLogsViewer, UFrmViewArchivedReports, UFrmLogSQLSteps,
  UFrmViewUserMachineSpecsLkp, ULowTypeHelpers;

procedure ActivateOption(SecurityID: Integer);
begin
  if CheckForRestart then
    Exit;
  case SecurityID of
    9800:
      TFrmLowSQLQuery.ExecuteShow(nil, SecurityID);
    9900:
      TFrmSecurityMaintenance.ExecuteShow(nil, SecurityID, 0, True);
    9932:
      TFrmActivateSecOptWzd.ExecuteModal(nil, nil, SecurityID, 0, True);
    9934:
      TFrmLogSQLSteps.ExecuteModal(nil, nil, SecurityID, 0, True);
    9940:
      TFrmSecurityLoggedInUsers.ExecuteLookup(nil, SecurityID);
    9949: {Help | Support Tools | View Logs}
      TFrmLogsViewer.ExecuteShow(nil, nil, SecurityID, 0, True, True, bsSizeable);
    9952:
      TFrmSecurityAuditHistoryWizard.ExecuteModal(nil, nil, SecurityID, 0, True);
    9954: {Help | Support Tools | View Workstation Info}
      TFrmViewUserMachineSpecsLkp.ExecuteLookup(nil, SecurityID);
    21001:
      TFrmInvDepositoriesLkp.ExecuteLookup(nil, SecurityID);
    21002:
      TFrmOtherSourcesLkp.ExecuteLookup(nil, SecurityID);
    21003:
      TFrmDepositoriesLkp.ExecuteLookup(nil, SecurityID);
    21004:
      TFrmSpecsMaint.ExecuteModal(nil, SecurityID, 0, True);
    21006:
      TFrmReportMsgLookup.ExecuteLookup(nil, SecurityID);
    21007:
      TFrmTaxUnitsLookup.ExecuteLookup(nil, SecurityID);
    21009: {Reference | Tax Units Crosswalk}
      TFrmTaxUnitsCrosswalkMaint.ExecuteModal(nil, nil, SecurityID, 0, True);
    21100:
      TFrmBeginningBalanceMaint.ExecuteModal(nil, nil, SecurityID, 0, True);
    21110:
      TFrmDailyEntryMaint.ExecuteModal(nil, SecurityID, 0, True);
    21112: {Data | Import from Tax System | Import Tax Data}
      TFrmImportFromTaxWzd.ExecuteModal(nil, nil, SecurityID, 0, True);
    21113: {Data | Import from Tax System | Import Settlement Data}
      TFrmImportFromTaxWzd.ExecuteModal(nil, nil, SecurityID, 0, True);
    21131:
      TFrmChangeCurBusinessDate.ExecuteModal(nil, nil, SecurityID, 0, True);
    21200:
      TFrmCashDepositBalRptWzd.ExecuteShow(nil, nil, SecurityID, 0, True);
    21300:
      TFrmNotesByDateSpan.ExecuteLookup(nil, SecurityID);
    21310: {Reports | View Archived Reports}
      TFrmViewArchivedReports.ExecuteLookup(nil, SecurityID, True);
  else
    LowMessageDlg('Security option ' + IntToStr(SecurityID) + ' has not been implemented.', mtError, [mbOK], 0);
  end;
end;

function CheckForRestart: Boolean;

  procedure MsgCancel(tmpCTL_ID: TCTL_ID);
  begin
    LowMessageDlg('The following option was started but did not complete successfully:'
      + CrLf + CrLf + StringReplace(tmpCTL_ID.OptionDescription, '&', '&&', [rfReplaceAll])
      + CrLf + CrLf + 'The option will be canceled. If the option must be completed, select it again from the menu.',
      mtInformation, [mbOK], 0);
  end;

  function MsgRestart(tmpCTL_ID: TCTL_ID): Boolean;
  begin
    if LowMessageDlg('The following option was started but did not complete successfully:'
      + CrLf + CrLf + StringReplace(tmpCTL_ID.OptionDescription, '&', '&&', [rfReplaceAll])
      + CrLf + CrLf + 'The option abnormally terminated at the following step:'
      + CrLf + CrLf + tmpCTL_ID.Restart_Step_Desc
      + CrLf + CrLf + 'This option must be completed. Do you wish to restart the option now?',
      mtInformation, [mbYes, mbNo], 0) = mrYes then
    begin
      Result := True;
    end
    else
    begin
      Result := False;
    end;
  end;

  procedure MsgException(tmpCTL_ID: TCTL_ID; ExceptMsg: string);
  begin
    LowMessageDlg(StringReplace(tmpCTL_ID.OptionDescription, '&', '&&', [rfReplaceAll])
      + CrLf + CrLf + 'CheckForRestart Error: ' + ExceptMsg + CrLf + CrLf + LowContactMessg, mtError, [mbOK], 0);
  end;

  procedure ReleaseOption(tmpCTL_ID: TCTL_ID);
  begin
    TObjSecurityRoutines.returnOption(IntToStr(tmpCTL_ID.Option_ID));
  end;

var
  tmpCTL_ID: TCTL_ID;
begin
  Result := False;
  tmpCTL_ID := TObjSecurityRoutines.CheckForRestart;
  try
    try
      if tmpCTL_ID.NumOfRestart > 0 then
      begin
        Result := True;
        // TODO: Uncomment out the following lines and insert appropriate security id
        //       edits in the case statement to implement additional in progress edits.
        //        case tmpCTL_ID.Option_ID of
        //          // TODO: Insert System ID Checks Here...
        //        else
        MsgCancel(tmpCTL_ID);
        ReleaseOption(tmpCTL_ID);
        //        end;
      end;
    except
      on e: Exception do
      begin
        MsgException(tmpCTL_ID, e.Message);
      end;
    end;
  finally
    FreeAndNil(tmpCTL_ID);
  end;
end;

end.
