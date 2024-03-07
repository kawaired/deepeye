using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MyTest : MonoBehaviour
{
    // Start is called before the first frame update
    public Transform testpro;

    private Vector3 rotaxi=new Vector3(0,1,0);
    private Quaternion pre=Quaternion.identity;
    private Quaternion cur=Quaternion.identity;
    void Start()
    {
        Debug.Log(Mathf.Sin(Mathf.Acos(0)));
        // Debug.Log(testpro.rotation);
        // Quaternion inversequa = Quaternion.Inverse(transform.rotation);
        // testpro.rotation=inversequa*testpro.rotation;
        // Debug.Log(testpro.rotation);
        // Debug.Log(transform.rotation);
        // Debug.Log(Quaternion.Inverse(transform.rotation));
        // Debug.Log(transform.rotation);
        // Vector3 testvector=new Vector3(2,3,3).normalized;
        // Quaternion rot=new Quaternion(testvector.x*0,testvector.y*0,testvector.z*0,1);
        // transform.rotation= rot*transform.rotation;
    }
    
    private void GetRotateAxi(Quaternion pre, Quaternion cur)
    {
        Quaternion change=ChangedQuaternion(pre,cur);
        // Debug.Log(change.w);
        if(Mathf.Abs(change.w-1)>0.0001)
        {
            // Debug.Log("1");
            float angle=Mathf.Acos(change.w);
            // Debug.Log(angle/Mathf.PI*180);
            float axifac=Mathf.Sin(Mathf.Acos(change.w));
            rotaxi=(new Vector3(change.x/axifac,change.y/axifac,change.z/axifac)).normalized;
        }
       
    }

    private Quaternion ChangedQuaternion(Quaternion pre, Quaternion cur)
    {
        return Quaternion.Inverse(pre)*cur;
    }

    // Update is called once per frame
    void Update()
    {
        pre=cur;
        cur=testpro.rotation;
        GetRotateAxi(pre,cur);
        // float testfac=Mathf.Sin(Mathf.Acos(testpro.rotation.w));
        // rotaxi=(new Vector3(testpro.rotation.x/testfac,testpro.rotation.y/testfac,testpro.rotation.z/testfac)).normalized;
        //  if(Mathf.Abs(testpro.rotation.w-1)>0.0001)
        // {
        //     float axifac=Mathf.Sin(Mathf.Acos(testpro.rotation.w));
        //     rotaxi=(testpro.rotation)
        //     rotaxi=(new Vector3(testpro.rotation.x/axifac,testpro.rotation.y/axifac,testpro.rotation.z/axifac)).normalized;
        // }
        //  Debug.Log(transform.rotation);
    }

    void OnDrawGizmos()
    {
        Gizmos.color=Color.yellow; 
        Gizmos.DrawLine(testpro.position,testpro.position+testpro.localToWorldMatrix.MultiplyVector(rotaxi)*3);
    }
}
