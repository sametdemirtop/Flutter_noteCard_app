import 'package:flutter/material.dart';
import 'package:flutter_not_sepeti/models/kategori.dart';
import 'package:flutter_not_sepeti/utils/databse_helper.dart';

import 'kategori_detay.dart';
import 'models/notlar.dart';
import 'not_detay.dart';

class Notlar extends StatefulWidget {
  @override
  _NotlarState createState() => _NotlarState();
}

class _NotlarState extends State<Notlar> {
  DatabaseHelper databaseHelper = DatabaseHelper();

  var _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Center(
          child: Text("Notlar"),
        ),
        actions: [
          PopupMenuButton(itemBuilder: (context) {
            return [
              PopupMenuItem(
                child: ListTile(
                  title: Text("Kategori"),
                  leading: CircleAvatar(
                    child: Icon(Icons.category),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    kategoriSayfasinaGit();
                  }
                ),
              ),
            ];
          }),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "KategoriEkle",
            tooltip: "Kategori Ekle",
            child: Icon(Icons.circle),
            onPressed: () {
              kategoriEkleDialog(context);
            },
            mini: true,
          ),
          FloatingActionButton(
              heroTag: "NotEkle",
              tooltip: "Not Ekle",
              child: Icon(Icons.add),
              onPressed: () {
                print("Not ekle butonuna tıklanıldı");
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NotDetay(
                              notBaslik: "Yeni Not",
                            ))).then((value) {
                  setState(() {});
                });
              }),
        ],
      ),
      body: Notlarbody(),
    );
  }

  void kategoriEkleDialog(BuildContext context) {
    var formKey = GlobalKey<FormState>();
    String yeniKategoriAdi;
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text("Kategori Ekle"),
          children: [
            Form(
              key: formKey,
              child: TextFormField(
                onSaved: (yeniKategori) {
                  yeniKategoriAdi = yeniKategori;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Kategori Adı",
                ),
                // ignore: missing_return
                validator: (girilendeger) {
                  if (girilendeger.length < 3) {
                    return "en az 3 karakter girilmeli";
                  }
                },
              ),
            ),
            ButtonBar(
              children: [
                RaisedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Vazgeç"),
                  color: Colors.teal,
                ),
                RaisedButton(
                  onPressed: () {
                    if (formKey.currentState.validate()) {
                      formKey.currentState.save();
                      databaseHelper.kategoriEkle(Kategori(yeniKategoriAdi)).then(
                        (kategoriID) {
                          if (kategoriID > 0) {
                            _scaffoldKey.currentState.showSnackBar(
                              SnackBar(
                                content: Text("Kategori EKlendi"),
                                duration: Duration(seconds: 1),
                              ),
                            );
                            Navigator.pop(context);
                          }
                          ;
                        },
                      );
                    }
                  },
                  child: Text(
                    "Kaydet",
                  ),
                  color: Colors.pink[200],
                )
              ],
            ),
          ],
        );
      },
    );
  }

  kategoriSayfasinaGit() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Kategoriler())).then((value) {
      setState(() {});
    });
  }
}

class Notlarbody extends StatefulWidget {
  @override
  _NotlarbodyState createState() => _NotlarbodyState();
}

class _NotlarbodyState extends State<Notlarbody> {
  List<Not> tumNotlar;
  DatabaseHelper databaseHelper = DatabaseHelper();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tumNotlar = List<Not>();
    databaseHelper = DatabaseHelper();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: databaseHelper.notListesiniGetir(),
        builder: (context, AsyncSnapshot<List<Not>> snapShot) {
          tumNotlar = snapShot.data;
          if (snapShot.connectionState == ConnectionState.done) {
            return ListView.builder(
                itemCount: tumNotlar.length,
                itemBuilder: (context, index) {
                  return ExpansionTile(
                      leading: oncelikDegeriAta(tumNotlar[index].notOncelik),
                      title: Text(tumNotlar[index].notBaslik),
                      subtitle: Text(tumNotlar[index].kategoriBaslik),
                      children: [
                        Container(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "Not İçeriği :",
                                      style: TextStyle(fontSize: 18, color: Colors.teal),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      tumNotlar[index].notIcerik == null ? "" : tumNotlar[index].notIcerik,
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("Oluşturulma Tarihi :", style: TextStyle(fontSize: 18, color: Colors.teal)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      databaseHelper.dateFormat(
                                        DateTime.parse(tumNotlar[index].notTarih),
                                      ),
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ],
                              ),
                              ButtonBar(
                                children: [
                                  FlatButton(
                                    onPressed: () {
                                      _notSil(tumNotlar[index].notID);
                                    },
                                    child: Text(
                                      "SİL",
                                    ),
                                    color: Colors.pink[200],
                                  ),
                                  FlatButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => NotDetay(
                                                    notBaslik: "Not Düzenle",
                                                    duzenlenecekNot: tumNotlar[index],
                                                  ))).then((value) {
                                        setState(() {});
                                      });
                                    },
                                    child: Text(
                                      "DÜZENLE",
                                    ),
                                    color: Colors.teal,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ]);
                  setState(() {});
                });
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  oncelikDegeriAta(int notOncelik) {
    switch (notOncelik) {
      case 0:
        return CircleAvatar(
          child: Text("L"),
          backgroundColor: Colors.pink[100],
        );
        break;
      case 1:
        return CircleAvatar(
          child: Text("M"),
          backgroundColor: Colors.pink[200],
        );
        break;
      case 2:
        return CircleAvatar(
          child: Text("H"),
          backgroundColor: Colors.pink[400],
        );
        break;
    }
  }

  void _notSil(int notID) async {
    setState(() {
      databaseHelper.notSil(notID).then((noID) {
        if (noID != 0) {
          Scaffold.of(context).showSnackBar(SnackBar(content: Text("Not Silindi")));
        }
      });
    });
  }
}
