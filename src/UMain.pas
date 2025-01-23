unit UMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ppEndUsr, ppComm, ppRelatv, ppProd,
  ppClass, ppReport,Vcl.StdCtrls, Vcl.ExtCtrls, ppModule, raCodMod, ppStrtch,
  ppMemo, ppPrnabl, ppCtrls, ppBands, ppCache, ppDesignLayer, ppParameter, ppTypes;

type
  TFrmMain = class(TForm)
    MyReport: TppReport;
    MyDesigner: TppDesigner;
    ppParameterList1: TppParameterList;
    Label1: TLabel;
    Label2: TLabel;
    GrpGender: TRadioGroup;
    Label3: TLabel;
    Label4: TLabel;
    edtName: TEdit;
    edtHeight: TEdit;
    edtWeight: TEdit;
    Button1: TButton;
    ppHeaderBand1: TppHeaderBand;
    lblHeader: TppLabel;
    lblResult: TppLabel;
    ppDetailBand1: TppDetailBand;
    ppLabel1: TppLabel;
    ppLabel2: TppLabel;
    lblName: TppLabel;
    lblGender: TppLabel;
    ppLabel5: TppLabel;
    ppLabel6: TppLabel;
    lblHeight: TppLabel;
    lblWeight: TppLabel;
    ppLabel3: TppLabel;
    lblRecommendation: TppMemo;
    ppFooterBand1: TppFooterBand;
    ppDesignLayers1: TppDesignLayers;
    ppDesignLayer1: TppDesignLayer;
    procedure Button1Click(Sender: TObject);
  private
    function CalculateBMI: string;
    function GenderColor(IdxGender: Integer):string;
    function GenderName(IdxGender: Integer): string;
    function GetRecommendation(BMIResult: String): string;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.dfm}

procedure TFrmMain.Button1Click(Sender: TObject);
begin
  var MyBMI := CalculateBMI;

  MyReport.Template.FileName := Concat(ExtractFilePath(Application.ExeName),'\report\MyReport.rtm');
  MyReport.Template.Load;

  var MyDetailBand := MyReport.GetBand(TppBandType.btDetail, 0);
  var MyHeaderBand := MyReport.GetBand(TppBandType.btHeader, 0);

  var MyCodeModule := TraCodeModule(MyReport.CodeModule);
  if MyCodeModule = nil then
    MyCodeModule := TraCodeModule.CreateForReport(MyReport);

  var MyHeaderBeforePrint := MyCodeModule.CreateEventHandler(MyHeaderBand, 'BeforePrint');
  MyHeaderBeforePrint.BodyText := 'lblResult.Caption := ''' + MyBMI + ''';';

  var MyDetailBeforePrint := MyCodeModule.CreateEventHandler(MyDetailBand, 'BeforePrint');
  MyDetailBeforePrint.BodyText := 'lblGender.Caption    := ''' + GenderName(GrpGender.ItemIndex) + '''; ' +
                                  'lblGender.Font.Color := ' + GenderColor(GrpGender.ItemIndex) + '; ' +
                                  'lblName.Caption      := ''' + edtName.Text + '''; ' +
                                  'lblHeight.Caption    := ''' + edtHeight.Text + '''; ' +
                                  'lblWeight.Caption    := ''' + edtWeight.Text + '''; ' +
                                  'lblRecommendation.Lines.Clear;' +
                                  'lblRecommendation.Lines.Text := ''' + GetRecommendation(MyBMI) + '''; ';

  MyCodeModule.BuildAll(True);
  MyReport.Print;
end;

function TFrmMain.CalculateBMI: string;
var
  Classification: string;
begin
  var Weight := StrToFloat(edtWeight.Text);
  var HeightInMeters := StrToFloat(edtHeight.Text)/100;

  var BMI := Weight / (HeightInMeters * HeightInMeters);

  if GrpGender.ItemIndex = 0 then
  begin
    if BMI < 20 then
      Classification := 'Underweight'
    else if BMI < 25 then
      Classification := 'Normal Weight'
    else if BMI < 30 then
      Classification := 'Overweight'
    else if BMI < 35 then
      Classification := 'Obesity Grade 1'
    else if BMI < 40 then
      Classification := 'Obesity Grade 2'
    else
      Classification := 'Obesidade Grade 3 (Morbid Obesity)';
  end
  else
  begin
    if BMI < 19 then
      Classification := 'Underweight'
    else if BMI < 24 then
      Classification := 'Normal Weight'
    else if BMI < 29 then
      Classification := 'Overweight'
    else if BMI < 34 then
      Classification := 'Obesity Grade 1'
    else if BMI < 39 then
      Classification := 'Obesity Grade 2'
    else
      Classification := 'Obesidade Grade 3 (Morbid Obesity)';
  end;

  Result := Format('BMI: %.2f - Classification: %s', [BMI, Classification]);
end;


function TFrmMain.GenderColor(IdxGender: Integer): string;
begin
  case IdxGender of
    0: Result := 'clBlue';
    1: Result := 'clRed';
  end;
end;

function TFrmMain.GenderName(IdxGender: Integer): string;
begin
  case IdxGender of
    0: Result := 'Male';
    1: Result := 'Female';
  end;
end;

function TFrmMain.GetRecommendation(BMIResult: String): string;
begin
  Result := '';
  if Pos('Underweight', BMIResult) > 0 then
    Result := 'You should focus on gaining weight in a healthy way. ' +
              'Consider increasing your caloric intake with nutritious foods such as whole grains, ' +
              'lean proteins, healthy fats, and vegetables. Consult a nutritionist or healthcare provider for a tailored plan.'
  else if Pos('Normal Weight', BMIResult) > 0 then
    Result := 'You are in a healthy weight range. Maintain your current lifestyle by balancing regular exercise, ' +
              'a nutritious diet, and adequate hydration. Keep monitoring your health to stay on track.'
  else if Pos('Overweight', BMIResult) > 0 then
    Result := 'You should aim to lose some weight for better health. Incorporate a balanced diet with reduced calorie intake, ' +
              'prioritize whole foods, and engage in regular physical activity such as walking, running, or strength training. ' +
              'A healthcare provider can help you set realistic goals.'
  else if Pos('Obesity Grade 1', BMIResult) > 0 then
    Result := 'Weight loss is essential to reduce health risks. Focus on a sustainable diet with reduced sugars, ' +
              'unhealthy fats, and processed foods. Engage in consistent physical activities and consult a doctor or dietitian for ' +
              'professional guidance.'
  else if Pos('Obesity Grade 2', BMIResult) > 0 then
    Result := 'Your weight poses significant health risks. It is important to follow a structured weight loss plan' +
              ' under medical supervision. A combination of a customized diet, exercise program, and possibly medication or ' +
              'other interventions may be recommended by a healthcare professional.'
  else
    Result := 'You are at a very high risk for serious health complications. ' +
              'Immediate action is needed under the guidance of a medical team. ' +
              'Consult with a doctor to explore options such as a supervised diet, behavioral therapy, and, in some cases, bariatric surgery.';


end;

end.
