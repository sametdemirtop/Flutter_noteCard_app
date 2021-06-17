import 'package:flutter/material.dart';
import 'package:flutter_not_sepeti/utils/databse_helper.dart';

import 'models/kategori.dart';
import 'models/notlar.dart';

class NotDetay extends StatefulWidget {
  String notBaslik = "Yeni Not";
  Not duzenlenecekNot;
  NotDetay({this.notBaslik, this.duzenlenecekNot});
  DatabaseHelper databaseHelper = DatabaseHelper();

  @override
  _NotDetayState createState() => _NotDetayState();
}

class _NotDetayState extends State<NotDetay> {
  var formKey = GlobalKey<FormState>();
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Kategori> tumKategoriler;
  DatabaseHelper databaseHelper;
  int kategoriID = 1;
  int oncelikID = 0;
  String notBaslik;
  String notIcerik;
  static var _oncelik = ["Düşük", "Orta", "Yüksek"];
  @override
  void initState() {
    super.initState();
    tumKategoriler = List<Kategori>();
    databaseHelper = DatabaseHelper();

    databaseHelper.kategorileriGetir().then((okunanmap) {
      for (Map okunacakmap in okunanmap) {
        tumKategoriler.add(Kategori.fromMap(okunacakmap));
      }
      if (widget.duzenlenecekNot != null) {
        kategoriID = widget.duzenlenecekNot.kategoriID;
        oncelikID = widget.duzenlenecekNot.notOncelik;
      } else {
        kategoriID = 1;
        oncelikID = 0;
        //secilenKategori = tumKategoriler[0];
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text("Yeni not"),
      ),
      body: Form(
        key: formKey,
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Text(
                    "Kategori :",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                Center(
                  child: Container(
                    child: DropdownButtonHideUnderline(
                      child: Center(
                        child: DropdownButton<int>(
                            items: kategoriItemleriOlustur(),
                            value: kategoriID,
                            onChanged: (secilenkategoriID) {
                              setState(() {
                                kategoriID = secilenkategoriID;
                              });
                            }),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 24),
                    margin: EdgeInsets.all(12),
                    decoration: BoxDecoration(border: Border.all(width: 2, color: Colors.teal), borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                initialValue: widget.duzenlenecekNot != null ? widget.duzenlenecekNot.notBaslik : "",
                validator: (baslik) {
                  if (baslik.length < 3) {
                    return "En az 3 karakter giriniz";
                  }
                },
                onSaved: (baslik) {
                  notBaslik = baslik;
                },
                decoration: InputDecoration(
                  hintText: "Not Başlığını Giriniz.",
                  labelText: "Başlık",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                initialValue: widget.duzenlenecekNot != null ? widget.duzenlenecekNot.notIcerik : "",
                validator: (icerik) {
                  if (icerik.length < 3) {
                    return "En az 3 karakter giriniz";
                  }
                },
                onSaved: (icerik) {
                  notIcerik = icerik;
                },
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Not İçeriğini Giriniz.",
                  labelText: "İçerik",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Text(
                      "Öncelik :",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 12),
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(border: Border.all(color: Colors.teal, width: 2), borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                          items: _oncelik.map((oncelik) {
                            return DropdownMenuItem<int>(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  oncelik,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              value: _oncelik.indexOf(oncelik),
                            );
                          }).toList(),
                          value: oncelikID,
                          onChanged: (secilenOncelikID) {
                            setState(() {
                              oncelikID = secilenOncelikID;
                            });
                          })),
                ),
              ],
            ),
            Expanded(
                child: ButtonBar(
              mainAxisSize: MainAxisSize.max,
              alignment: MainAxisAlignment.end,
              children: [
                RaisedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  color: Colors.pink[200],
                  child: Text("Vazgeç"),
                ),
                RaisedButton(
                  onPressed: () {
                    if (formKey.currentState.validate()) {
                      formKey.currentState.save();
                      var suan = DateTime.now();
                      if (widget.duzenlenecekNot == null) {
                        setState(() {
                          databaseHelper
                              .notEkle(Not(
                            kategoriID,
                            notBaslik,
                            notIcerik,
                            suan.toString(),
                            oncelikID,
                          ))
                              .then((kaydedilennotID) {
                            if (kaydedilennotID >= 0) {
                              _scaffoldKey.currentState.showSnackBar(
                                SnackBar(
                                  content: Text("Not EKlendi"),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            }
                          });
                        });
                      } else {
                        setState(() {
                          databaseHelper
                              .notGuncelle(Not.withID(widget.duzenlenecekNot.notID, kategoriID, notBaslik, notIcerik, suan.toString(), oncelikID))
                              .then((not) {
                            if (not == widget.duzenlenecekNot.notID) {
                              _scaffoldKey.currentState.showSnackBar(
                                SnackBar(
                                  content: Text("Not Düzenlendi"),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            }
                          });
                        });
                      }
                    }
                    Navigator.pop(context);
                    setState(() {});
                  },
                  color: Colors.teal,
                  child: Text("Kaydet"),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<int>> kategoriItemleriOlustur() {
    print("Notlar için kategori itemleri oluşuturuldu");
    return tumKategoriler
        .map((kategori) => DropdownMenuItem<int>(
              value: kategori.kategoriID,
              child: Text(
                kategori.kategoriBaslik,
                style: TextStyle(fontSize: 18),
              ),
            ))
        .toList();
  }
}
