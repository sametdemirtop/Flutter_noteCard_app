import 'package:flutter/material.dart';
import 'package:flutter_not_sepeti/models/kategori.dart';
import 'package:flutter_not_sepeti/utils/databse_helper.dart';

class Kategoriler extends StatefulWidget {
  Kategori duzenlenecekKategori;
  Kategoriler({this.duzenlenecekKategori});
  @override
  _KategorilerState createState() => _KategorilerState();
}

class _KategorilerState extends State<Kategoriler> {
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Kategori> tumKategoriler1;
  DatabaseHelper databaseHelper;

  @override
  void initState() {
    super.initState();
    databaseHelper = DatabaseHelper();
  }

  @override
  Widget build(BuildContext context) {
    if (tumKategoriler1 == null) {
      tumKategoriler1 = List<Kategori>();
      kategoriListesiniGuncelle();
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Kategoriler"),
      ),
      body: ListView.builder(
          itemCount: tumKategoriler1.length,
          itemBuilder: (context, index) {
            return ListTile(
                title: Text(tumKategoriler1[index].kategoriBaslik),
                onTap: () {
                  setState(() {
                    _kategoriGuncelle(tumKategoriler1[index], context);
                  });
                },
                trailing: InkWell(
                  child: Icon(Icons.auto_delete),
                  onTap: () {
                    _kategoriSil(tumKategoriler1[index].kategoriID);
                  },
                ),
                leading: CircleAvatar(
                  child: Text(tumKategoriler1[index].kategoriID.toString()),
                ));
            setState(() {});
          }),
    );
  }

  void kategoriListesiniGuncelle() {
    databaseHelper.kategoriListesiniGetir().then((value) => {
          setState(() {
            tumKategoriler1 = value;
          })
        });
  }

  _kategoriSil(int kategoriID) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text("Kategori Sil"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text("Kategoriyi sildiğinizde bununla ilgili tüm notlar da silinecektir.\n\nEmin Misiniz ?"),
                ButtonBar(
                  children: <Widget>[
                    OutlineButton(
                      borderSide: BorderSide(color: Theme.of(context).primaryColor),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Vazgeç",
                        style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                    ),
                    OutlineButton(
                      borderSide: BorderSide(color: Theme.of(context).accentColor),
                      onPressed: () {
                        databaseHelper.kategoriSil(kategoriID).then((silinenKategori) {
                          if (silinenKategori != 0) {
                            setState(() {
                              kategoriListesiniGuncelle();
                              Navigator.pop(context);
                            });
                          }
                        });
                      },
                      child: Text(
                        "Sil",
                        style: TextStyle(color: Theme.of(context).accentColor, fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }

  _kategoriGuncelle(Kategori guncellencekKategori, BuildContext c) {
    kategoriGuncelleDialog(c, guncellencekKategori);
  }

  void kategoriGuncelleDialog(BuildContext myContext, Kategori guncellencekKategori) {
    var formKey = GlobalKey<FormState>();
    String guncellenenKategoriAdi;
    showDialog(
      barrierDismissible: false,
      context: myContext,
      builder: (context) {
        return SimpleDialog(
          title: Text("Kategori Güncelle"),
          children: [
            Form(
              key: formKey,
              child: TextFormField(
                initialValue: guncellencekKategori.kategoriBaslik,
                onSaved: (yeniKategori) {
                  guncellenenKategoriAdi = yeniKategori;
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
                    setState(() {
                      if (formKey.currentState.validate()) {
                        formKey.currentState.save();
                        databaseHelper.kategoriGuncelle(Kategori.withID(guncellencekKategori.kategoriID, guncellenenKategoriAdi)).then(
                          (katID) {
                            if (katID != 0) {
                              Scaffold.of(myContext).showSnackBar(
                                SnackBar(
                                  content: Text("Kategori Güncellendi"),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                              kategoriListesiniGuncelle();
                              Navigator.of(context).pop();
                            }
                            setState(() {});
                          },
                        );
                      }
                    });
                  },
                  child: Text(
                    "Güncelle",
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
}
