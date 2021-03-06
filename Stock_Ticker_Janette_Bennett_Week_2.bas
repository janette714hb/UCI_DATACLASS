Attribute VB_Name = "Module1"
Sub Ticker()

  ' Set an initial variable for holding the Ticker_Name
  Dim Ticker_Name As String

  ' Set an initial variable for Ticker Value
  Dim Ticker_Value As Double
  Ticker_Value = 0

' Set variable for Yearly_Change
  Dim Yearly_Change As Double

'Set Variance for Percent_Change
  Dim Percent_Change As Double

  'Name Columns for Ticker Name and Ticker Value
  Cells(1, 10).Value = "Ticker Name"
  Cells(1, 11).Value = "Ticker Value"

  ' Keep track of the location for Ticker Value in Total Table
    Dim Ticker_Table_Row As Integer
    Ticker_Table_Row = 2

  ' Loop through all Ticker Values
  LastRow = Cells(Rows.Count, 1).End(xlUp).Row
  For i = 2 To LastRow

    ' Check if we are still within the same ticker symbol, if it is not...
    If Cells(i + 1, 1).Value <> Cells(i, 1).Value Then

      ' Set the Ticker Name
      Ticker_Name = Cells(i, 1).Value

      ' Add to the Ticker Value
      Ticker_Value = Ticker_Value + Cells(i, 7).Value

      ' Print the Ticker Value in the Total Table
      Range("J" & Ticker_Table_Row).Value = Ticker_Name

      ' Print the Brand Amount to the Ticker Table
      Range("K" & Ticker_Table_Row).Value = Ticker_Value

      ' Add one to the Ticker table row
      Ticker_Table_Row = Ticker_Table_Row + 1
      
      ' Reset the Ticker Total
      Ticker_Value = 0

    ' If the cell immediately following a row is the Ticker Symbol
    Else

      ' Add to the Ticker value
      Ticker_Value = Ticker_Value + Cells(i, 7).Value

    End If

  Next i
 
End Sub
